package threesevens.random_music_player

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.distribute.Distribute
import com.microsoft.appcenter.distribute.UpdateTrack

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var API_KEY: String = "";
        if(System.getenv("isAppCenter") != null){
            API_KEY = System.getenv("API_KEY").toString()
        }else {
            API_KEY = getString(R.string.API_KEY).toString()
        }
        Distribute.setUpdateTrack(UpdateTrack.PUBLIC);
        AppCenter.start(application, API_KEY,
                Analytics::class.java, Crashes::class.java, Distribute::class.java)
        AppCenter.setLogLevel(Log.VERBOSE)
    }
}
