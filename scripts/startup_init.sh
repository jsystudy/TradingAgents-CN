#!/bin/bash
# 启动时自动初始化管理员用户

echo "🔧 正在初始化管理员用户..."

# 获取当前容器ID
CONTAINER_ID=$(hostname)
DB_NAME="tradingagentscn_v0_root-${CONTAINER_ID}"

# 使用Python创建管理员用户
python -c "
import hashlib
import sys
from pymongo import MongoClient

try:
    MONGO_URI = 'mongodb://admin:tradingagents123@mongodb:27017/${DB_NAME}?authSource=admin'
    client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    client.admin.command('ping')
    db = client['${DB_NAME}']
    
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
