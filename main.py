# main.py
import os
import json
import chess
import chess.engine
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.orm import Session

# Импорты из твоего файла database.py
from database import init_db, get_db, get_user_profile, get_user_progress, update_user_stats, complete_level, Task

STOCKFISH_PATH = r"stockfish-windows-x86-64-avx2.exe"

init_db()
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class MoveRequest(BaseModel):
    fen: str
    bot_level: int

@app.post("/api/engine/move")
def engine_move(request: MoveRequest):
    print(f"🤖 Запрос хода для FEN: {request.fen}")
    if not os.path.exists(STOCKFISH_PATH):
        return {"best_move": "e2e4", "error": "Stockfish not found"}
    
    try:
        engine = chess.engine.SimpleEngine.popen_uci(STOCKFISH_PATH)
        board = chess.Board(request.fen)
        think_time = 0.1 if request.bot_level == 0 else 0.5
        result = engine.play(board, chess.engine.Limit(time=think_time))
        move = result.move.uci()
        engine.quit()
        print(f"✅ Бот ответил: {move}")
        return {"best_move": move}
    except Exception as e:
        print(f"❌ Ошибка Стокфиша: {e}")
        return {"error": str(e)}

@app.get("/api/progress/path")
def get_progress_endpoint(user_id: int = 1, db: Session = Depends(get_db)):
    print(f"📈 Запрос прогресса для юзера {user_id}")
    try:
        raw = get_user_progress(db, user_id)
        # ФОКУС: Флаттер ждет СЛОВАРЬ с ключом completed_levels
        ids = [p.level_id for p in raw]
        return {"completed_levels": ids}
    except Exception as e:
        print(f"❌ Ошибка БД (прогресс): {e}")
        return {"completed_levels": []}

@app.get("/api/tasks")
def get_tasks_endpoint(db: Session = Depends(get_db)):
    print("📋 Запрос списка задач")
    try:
        tasks = db.query(Task).all()
        result = []
        for t in tasks:
            # Безопасно достаем тип, даже если колонки еще нет в SQLAlchemy модели
            t_type = getattr(t, 'type', 'puzzle')
            result.append({
                "id": t.id,
                "title": t.title,
                "description": t.description,
                "category": t.category,
                "fen": t.fen,
                "solution": json.loads(t.solution) if t.solution else [],
                "type": t_type
            })
        return result
    except Exception as e:
        print(f"❌ Ошибка БД (задачи): {e}")
        return []

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)