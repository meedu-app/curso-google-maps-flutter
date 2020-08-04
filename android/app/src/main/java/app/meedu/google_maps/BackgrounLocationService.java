package app.meedu.google_maps;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;

public class BackgrounLocationService extends Service {
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return new Binder();
    }

    final int PRIORITY_HIGH = 1;


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent =
                PendingIntent.getActivity(this, 0, notificationIntent, 0);

        Notification.Builder builder = new Notification.Builder(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel("app.meedu/background-location",
                    "Meedu.app Background Location",
                    NotificationManager.IMPORTANCE_DEFAULT);

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(notificationChannel);


            builder.setChannelId("app.meedu/background-location");
        }

        builder.setContentTitle("MEEDU.APP")
                .setContentText("Escuchando cambios en la ubicación")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent);

        Notification notification = builder.build();

        startForeground(PRIORITY_HIGH, notification);

        return START_NOT_STICKY;
    }
}
