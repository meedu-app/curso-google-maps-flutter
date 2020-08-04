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


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        MethodChannel channel = new MethodChannel(messenger, "app.meedu/background-location");

        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "start":
                    start();
                    break;

                case "stop":
                    stop();
                    break;

                default:
                    result.notImplemented();
            }
        });
    }


    void start() {

        Intent intent = new Intent(this, BackgrounLocationService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent);
        } else {
            startService(intent);
        }

    }


    void stop() {
        Intent intent = new Intent(this, BackgrounLocationService.class);
        stopService(intent);
    }

    @Override
    protected void onDestroy() {
        stop();
        super.onDestroy();
    }
}
