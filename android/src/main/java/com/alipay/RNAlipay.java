package com.alipay;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.alipay.sdk.app.PayTask;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;

public class RNAlipay extends ReactContextBaseJavaModule{

    private static final String TAG = "RNAlipay";

    public RNAlipay(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @ReactMethod
    public void pay(final String payInfo,
                    final Callback callback) {

        Runnable payRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    PayTask alipay = new PayTask(getCurrentActivity());
                    Map<String, String> result = alipay.payV2(payInfo, true);
                    WritableMap mWritableMap = Arguments.createMap();
                    mWritableMap.putString("memo", result.get("memo"));
                    mWritableMap.putString("result", result.get("result"));
                    mWritableMap.putString("resultStatus", result.get("resultStatus"));
                    callback.invoke(mWritableMap);
                } catch (Exception e) {
                    WritableMap mWritableMap = Arguments.createMap();
                    callback.invoke(mWritableMap);
                }
            }
        };

        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }

    @Override
    public String getName() {
        return "RNAlipay";
    }

}
