"""临时数据导入端点"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from datetime import datetime

router = APIRouter()

class StockDataRecord(BaseModel):
    symbol: str
    stock_code: str
    stock_name: str
    trade_date: str
    open: float
    close: float
    high: float
    low: float
    volume: float
    amount: float = 0
    amplitude: float = 0
    change_pct: float = 0
    change_amount: float = 0
    turnover: float = 0

class ImportRequest(BaseModel):
    records: List[StockDataRecord]

@router.post("/import/stock-data")
async def import_stock_data(req: ImportRequest):
    """导入股票历史数据"""
    try:
        from app.core.database import get_mongo_db
        db = get_mongo_db()
        collection = db["stock_historical_data"]
        
        inserted = 0
        for r in req.records:
            doc = r.model_dump()
            doc["data_source"] = "akshare"
            doc["updated_at"] = datetime.utcnow()
            # upsert by symbol+trade_date
            await collection.update_one(
                {"symbol": r.symbol, "trade_date": r.trade_date, "data_source": "akshare"},
                {"$set": doc},
                upsert=True
            )
            inserted += 1
        
        # 更新stock_basic_info
        if req.records:
            basic_col = db["stock_basic_info"]
            r = req.records[0]
            await basic_col.update_one(
                {"symbol": r.symbol},
                {"$set": {
                    "symbol": r.symbol, "stock_code": r.stock_code,
                    "name": r.stock_name, "market_type": "cn_stock",
                    "data_source": "akshare", "is_active": True,
                    "updated_at": datetime.utcnow()
                }},
                upsert=True
            )
        
        return {"success": True, "message": f"导入 {inserted} 条记录", "count": inserted}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 注册路由
def register_import_router(app):
    app.include_router(router, prefix="/api/data", tags=["data-import"])
