#!/bin/bash
# 启动时自动初始化管理员用户

echo "🔧 正在初始化管理员用户..."

# 从环境变量获取 MongoDB 连接字符串
MONGO_URI="${MONGODB_URL:-mongodb://admin:tradingagents123@mongodb:27017/tradingagents?authSource=admin}"

# 使用Python创建管理员用户
python -c "
import hashlib
import sys
from pymongo import MongoClient
import os

try:
    MONGO_URI = '${MONGO_URI}'
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=10000)
    client.admin.command('ping')
    
    # 获取数据库名称（从 URI 中提取或使用默认值）
    db_name = 'tradingagents'
    if '/' in MONGO_URI:
        db_part = MONGO_URI.split('/')[-1]
        if '?' in db_part:
            db_name = db_part.split('?')[0]
        else:
            db_name = db_part
    
    db = client[db_name]
    
    existing = db.users.find_one({'username': 'admin'})
    if existing:
        print('✅ 管理员用户已存在')
    else:
        hashed = hashlib.sha256('admin123'.encode()).hexdigest()
        user_doc = {
            'username': 'admin',
            'email': 'admin@tradingagents.cn',
            'hashed_password': hashed,
            'is_active': True,
            'is_verified': True,
            'is_admin': True,
            'daily_quota': 10000,
            'concurrent_limit': 10,
            'total_analyses': 0,
            'successful_analyses': 0,
            'failed_analyses': 0,
            'favorite_stocks': []
        }
        db.users.insert_one(user_doc)
        print('✅ 管理员用户创建成功 (admin/admin123)')
except Exception as e:
    print(f'⚠️ 管理员初始化失败: {e}')
    print('   将在应用启动后重试')
"

echo "🚀 启动 FastAPI 服务..."
exec python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
