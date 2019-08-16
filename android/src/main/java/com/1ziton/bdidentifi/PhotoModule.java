package com.dashixiong.baiduIdentifi;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * 分享组件
 */

public class PhotoModule extends ReactContextBaseJavaModule{
    private BankPhoto bankPhoto;
    public PhotoModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "BankPhoto";
    }
    @ReactMethod
    public  void photo(final Promise successCallback) {
        getBankPhoto().photo(successCallback);
    }

    private BankPhoto getBankPhoto() {
        if(bankPhoto == null){
            bankPhoto = BankPhoto.of(getCurrentActivity());
            getReactApplicationContext().addActivityEventListener(bankPhoto);
        }else{
            bankPhoto.updateActivity(getCurrentActivity());
        }
        return bankPhoto;

    }
    @ReactMethod
    public void openCamera(final Promise successCallback) {
        getBankPhoto().openCamera(successCallback);
    }

}
