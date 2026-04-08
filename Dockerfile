# Используем официальный образ Python нужной версии (slim-версия весит меньше)
FROM python:3.10.13-slim

# Устанавливаем переменные окружения, чтобы Python не писал .pyc файлы и не буферизировал вывод
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Устанавливаем системные зависимости:
# ffmpeg - для работы yt-dlp (обработка аудио и видео)
# fonts-dejavu - для корректного отображения кириллицы в графиках matplotlib
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    fonts-dejavu \
    libsm6 \
    libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Создаем рабочую директорию
WORKDIR /app

# Копируем файл с зависимостями и устанавливаем их
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копируем весь остальной исходный код бота в контейнер
COPY . /app/

# Создаем папки, которые бот использует для временных файлов и логов,
# чтобы избежать ошибок "No such file or directory"
RUN mkdir -p /app/logs /app/downloads /app/output

# Открываем 80 порт (на нем работает Flask из вашего background.py)
EXPOSE 80

# Запускаем основного бота
CMD ["python", "fumy.py"]
