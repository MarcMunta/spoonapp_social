#!/bin/bash

echo "🔔 Setting up notification system..."

# Activate virtual environment if it exists
if [ -d "env" ]; then
    source env/bin/activate
    echo "✅ Virtual environment activated"
fi

# Create and apply migrations
echo "📝 Creating migrations..."
python manage.py makemigrations

echo "🚀 Applying migrations..."
python manage.py migrate

# Create missing files for the notification system
echo "📂 Creating missing files for the notification system..."
touch notifications/models.py
touch notifications/views.py
touch notifications/urls.py
touch notifications/templates/notifications/notification_list.html
touch notifications/templates/notifications/notification_detail.html

echo "✅ Missing files created!"

echo "✅ Notification system setup complete!"
echo ""
echo "🎉 You can now:"
echo "   - Receive notifications when someone sends you a message"
echo "   - See notification count in the topbar"
echo "   - View all notifications at /notifications/"
echo "   - Mark notifications as read"