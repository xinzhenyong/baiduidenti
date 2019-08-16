package com.dashixiong.baiduIdentifi;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapRegionDecoder;
import android.graphics.Rect;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.baidu.ocr.sdk.model.BankCardResult;
import com.baidu.ocr.ui.camera.CameraActivity;
import com.baidu.ocr.ui.camera.PermissionCallback;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import com.dashixiong.R;

public class BankPhoto implements ActivityEventListener {
    private static final int REQUEST_CODE_BANKCARD = 111;
    private static final int REQUEST_CODE_CARAMER = 112;

    private static final int PERMISSIONS_REQUEST_CAMERA = 800;
    private AlertDialog.Builder alertDialog;
    private static WeakReference<Activity> mActivity;
    Promise promise;
    private static final String PIC_NAME = "pic.jpg";

    public static BankPhoto of(Activity activity) {
        mActivity = new WeakReference<>(activity);
        return new BankPhoto();
    }
    public void updateActivity(Activity activity){
        mActivity = new WeakReference<>(activity);
    }

    private PermissionCallback permissionCallback = new PermissionCallback() {
        @Override
        public boolean onRequestPermission() {
            ActivityCompat.requestPermissions(mActivity.get(),
                    new String[] {Manifest.permission.CAMERA},
                    PERMISSIONS_REQUEST_CAMERA);
            return false;
        }
    };
    public void photo(Promise promise){
        this.promise=promise;
        Intent intent = new Intent(mActivity.get(), CameraActivity.class);
        intent.putExtra(CameraActivity.KEY_OUTPUT_FILE_PATH,
                getSaveFile(mActivity.get().getApplication()).getAbsolutePath());
        intent.putExtra(CameraActivity.KEY_CONTENT_TYPE,
                CameraActivity.CONTENT_TYPE_BANK_CARD);
        mActivity.get().startActivityForResult(intent, REQUEST_CODE_BANKCARD);
    }
    private void initPerrmission(){
//        if (ActivityCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.READ_EXTERNAL_STORAGE)
//                != PackageManager.PERMISSION_GRANTED) {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
//                ActivityCompat.requestPermissions(mActivity.get(),
//                        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
//                        PERMISSIONS_EXTERNAL_STORAGE);
//                return;
//            }
//        }
//        Intent intent = new Intent(Intent.ACTION_PICK);
//        intent.setType("image/*");
//        startActivityForResult(intent, REQUEST_CODE_PICK_IMAGE);
    }

    public void openCamera(Promise promise){
        this.promise = promise;
//        ActivityCompat.requestPermissions(mActivity.get(),
//                new String[] {Manifest.permission.CAMERA},
//                PERMISSIONS_REQUEST_CAMERA);
//        Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//        cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(
//                new File(Environment.getExternalStorageDirectory(), PIC_NAME)));
//        File file = new File(Environment.getExternalStorageDirectory(), PIC_NAME);
//        try {
//            file = createOriImageFile();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//
//        if (file != null) {
//            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
//                imgUriOri = Uri.fromFile(file);
//            } else {
//                imgUriOri = FileProvider.getUriForFile(this, getPackageName() + ".provider", file);
//            }
//            cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, imgUriOri);
//            mActivity.get().startActivityForResult(cameraIntent, REQUEST_CODE_CARAMER);
//        }
    }
    public static File getSaveFile(Context context) {
        File file = new File(context.getFilesDir(), "pic.jpg");
        return file;
    }

    private void infoPopText(final BankCardResult result,Promise promise) {
        if (mActivity == null) return;
        showDialog(result,promise);
//        alertText("", result);
    }
    private void alertText(final String title, final String message) {
        if (mActivity == null) return;
        mActivity.get().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                alertDialog = new AlertDialog.Builder(mActivity.get());
                alertDialog.setTitle(title)
                        .setMessage(message)
                        .setPositiveButton("确定", null)
                        .show();
            }
        });
    }
    private void showDialog(final BankCardResult result,final Promise promise){
        if (mActivity == null) return;
        mActivity.get().runOnUiThread(new Runnable() {
                  @Override
                  public void run() {
                      Dialog dialog = new Dialog(mActivity.get());
                      View contentView = LayoutInflater.from(mActivity.get()).inflate(R.layout.bank_card_info,null);
                      ImageView cancelImage = contentView.findViewById(R.id.cancel);
                      ImageView bankCardPic = contentView.findViewById(R.id.bankCardPic);
                      final EditText editNumF = contentView.findViewById(R.id.editNumF);
                      final EditText editNumS = contentView.findViewById(R.id.editNumS);
                      final EditText editNumT = contentView.findViewById(R.id.editNumT);
                      Button determin = contentView.findViewById(R.id.determin);
                      String cardNum = result.getBankCardNumber().replace(" ","");
                      editNumF.setText(cardNum.substring(0,7));
                      editNumS.setText(cardNum.substring(7,13));
                      editNumT.setText(cardNum.substring(13,cardNum.length()));
                      showPic(bankCardPic);
                      cancelImage.setOnClickListener(new View.OnClickListener() {
                          @Override
                          public void onClick(View v) {
                              dialog.dismiss();
                          }
                      });
                      determin.setOnClickListener(new View.OnClickListener() {
                          @Override
                          public void onClick(View v) {
                              StringBuffer sbf = new StringBuffer();
                              sbf.append(editNumF.getText().toString().trim()).
                              append(editNumS.getText().toString().trim()).
                              append(editNumT.getText().toString().trim());
//                              if(sbf.toString().length() < 19){
//                                  Toast.makeText(mActivity.get(),"请输入正确的银行卡号",Toast.LENGTH_SHORT).show();
//                                  return;
//                              }
                              JSONObject jsonObject = new JSONObject();
                              try {
                                  jsonObject.put("BankCardNumber",sbf.toString());
                                  jsonObject.put("BankCardType",result.getBankCardType().name());
                                  jsonObject.put("BankName",result.getBankName());
                              } catch (JSONException e) {
                                  e.printStackTrace();
                              }
                              promise.resolve(jsonObject.toString());
                              dialog.dismiss();
                          }
                      });
                      dialog.setContentView(contentView);
                      dialog.show();
                  }
              });

    }

    private void showPic(ImageView bankCardPic) {
        //设置显示图片的参数，如果对图片质量有要求，就选择ARGB_8888模式
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inPreferredConfig = Bitmap.Config.ARGB_8888;

        //获取图片的宽高
        InputStream is = null;
        BitmapRegionDecoder mDecoder = null;
        try {
            File imageFile = getSaveFile(mActivity.get());
            is = new FileInputStream(imageFile);
            //初始化BitmapRegionDecode，并用它来显示图片
            mDecoder = BitmapRegionDecoder
                    .newInstance(is, false);
            Bitmap source = BitmapFactory.decodeFile(imageFile.getAbsolutePath(),options);
            int imageWidth = source.getWidth();
            int height = source.getHeight();
//            Log.e("width",""+imageWidth);
//            Log.e("height",""+height);
//            Bitmap bitmap = mDecoder.decodeRegion(new Rect(0,200 ,600,312),options);
            Bitmap bitmap = mDecoder.decodeRegion(new Rect(0,height/2 ,imageWidth,3*height/4),options);
            bankCardPic.setImageBitmap(bitmap);
//            source.recycle();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

        }
    }


    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        // 识别成功回调，银行卡识别
        if (requestCode == REQUEST_CODE_BANKCARD && resultCode == Activity.RESULT_OK) {
            RecognizeService.recBankCard(mActivity.get(), getSaveFile(mActivity.get().getApplicationContext()).getAbsolutePath(),
                    new RecognizeService.ServiceListener() {
                        @Override
                        public void onResult(BankCardResult result) {
                            infoPopText(result,promise);
//                            promise.resolve(result);
                        }

                        @Override
                        public void onError(String error) {
                            promise.resolve(error);
                        }
                    });
        }else if(requestCode == REQUEST_CODE_CARAMER && resultCode == Activity.RESULT_OK){
            promise.resolve(Environment.getExternalStorageDirectory()+ PIC_NAME);
        }
    }

    @Override
    public void onNewIntent(Intent intent) {

    }
}
