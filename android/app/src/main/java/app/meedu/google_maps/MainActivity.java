package app.meedu.google_maps;

import android.content.Intent;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    boolean running = false;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        MethodChannel channel = new MethodChannel(messenger, "app.meedu/geolocation");
        channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                switch (call.method) {
                    case "start":

                        startForegroundLocationService();
                        break;

                    case "stop":
                        stopForegroundLocationService();
                        break;


                    default:
                        result.notImplemented();

                }
            }
        });
    }


    void startForegroundLocationService() {
        if (running) {
            return;
        }
        running = true;
        Intent intent = new Intent(this, BackgroundLocationService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent);
        } else {
            startService(intent);
        }
    }


    void stopForegroundLocationService() {
        if (running) {
            Intent intent = new Intent(this, BackgroundLocationService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                stopForegroundLocationService();
            } else {
                stopService(intent);
            }
            running = false;
        }
    }

    @Override
    protected void onDestroy() {
        stopForegroundLocationService();
        super.onDestroy();
    }
}
