package threesevens.random_music_player;

import com.instabug.instabugflutter.InstabugFlutterPlugin;

import java.util.ArrayList;


import io.flutter.app.FlutterApplication;

public class CustomFlutterApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        ArrayList<String> invocationEvents = new ArrayList<>();
        invocationEvents.add(InstabugFlutterPlugin.INVOCATION_EVENT_NONE);
        new InstabugFlutterPlugin().start(CustomFlutterApplication.this,
                getString(R.string.IB_TOKEN),
                invocationEvents);
    }


}
