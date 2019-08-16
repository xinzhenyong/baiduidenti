/*
 * Copyright (C) 2017 Baidu, Inc. All Rights Reserved.
 */
package com.dashixiong.baiduIdentifi;

import android.content.Context;

import com.baidu.ocr.sdk.OCR;
import com.baidu.ocr.sdk.OnResultListener;
import com.baidu.ocr.sdk.exception.OCRError;
import com.baidu.ocr.sdk.model.BankCardParams;
import com.baidu.ocr.sdk.model.BankCardResult;

import java.io.File;

/**
 * Created by ruanshimin on 2017/4/20.
 */

public class RecognizeService {

    interface ServiceListener {
        public void onResult(BankCardResult result);
        public void onError(String error);
    }

    public static void recBankCard(Context ctx, String filePath, final ServiceListener listener) {
        BankCardParams param = new BankCardParams();
        param.setImageFile(new File(filePath));
        OCR.getInstance(ctx).recognizeBankCard(param, new OnResultListener<BankCardResult>() {
            @Override
            public void onResult(BankCardResult result) {
//                String res = String.format("卡号：%s\n类型：%s\n发卡行：%s",
////                        result.getBankCardNumber(),
////                        result.getBankCardType().name(),
////                        result.getBankName());
                listener.onResult(result);
            }

            @Override
            public void onError(OCRError error) {
                listener.onError(error.getMessage());
            }
        });
    }
}
