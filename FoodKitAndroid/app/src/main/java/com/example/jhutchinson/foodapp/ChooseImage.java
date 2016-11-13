package com.example.jhutchinson.foodapp;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.fitness.Fitness;
import com.google.android.gms.fitness.data.DataPoint;
import com.google.android.gms.fitness.data.DataSet;
import com.google.android.gms.fitness.data.DataSource;
import com.google.android.gms.fitness.data.DataType;
import com.google.android.gms.fitness.data.Field;
import com.google.android.gms.fitness.request.DataUpdateRequest;
import com.ibm.watson.developer_cloud.android.library.camera.CameraHelper;
import com.ibm.watson.developer_cloud.visual_recognition.v3.VisualRecognition;
import com.ibm.watson.developer_cloud.visual_recognition.v3.model.ClassifyImagesOptions;
import com.ibm.watson.developer_cloud.visual_recognition.v3.model.VisualClassification;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;


public class ChooseImage extends AppCompatActivity {

    private GoogleApiClient apiClient;
    public  String[] sVals = new String[5];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chooseimage);

        Bundle intent = this.getIntent().getExtras();

        if (!intent.getString("l0").isEmpty()) {
            for (int i=0; i<5; i++){
                sVals[i] = intent.getString("l" + i);
            }
        }


        apiClient = new GoogleApiClient.Builder(this)
                .addApi(Fitness.HISTORY_API)
                .addScope(new Scope(Scopes.FITNESS_NUTRITION_READ_WRITE))
                .addConnectionCallbacks(
                        new GoogleApiClient.ConnectionCallbacks() {
                            @Override
                            public void onConnected(Bundle bundle) {
                                System.out.println("Connected");
                            }

                            @Override
                            public void onConnectionSuspended(int i) {
                                // If your connection to the sensor gets lost at some point,
                                // you'll be able to determine the reason and react to it here.
                                if (i == GoogleApiClient.ConnectionCallbacks.CAUSE_NETWORK_LOST) {
                                    System.out.println("Connection Lost");
                                } else if (i
                                        == GoogleApiClient.ConnectionCallbacks.CAUSE_SERVICE_DISCONNECTED) {
                                    System.out.println("Disconnected");
                                }
                            }
                        }
                ).enableAutoManage(this, 0, new GoogleApiClient.OnConnectionFailedListener() {
                    @Override
                    public void onConnectionFailed(ConnectionResult result) {
                        System.out.println("Connection Failed");
                    }
                })
                .build();
    }

    static final int REQUEST_IMAGE_CAPTURE = 1;

    public void takeImage(View view){

        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
        }


    }

    public void goBack(View view){
        try
        {
            Intent k = new Intent(ChooseImage.this, Overview.class);
            for (int i=0; i<5; i++){
                k.putExtra("l" + i, sVals[i]);
            }
            startActivity(k);
        }catch(Exception e){

        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
            Bundle extras = data.getExtras();
            Bitmap imageBitmap = (Bitmap) extras.get("data");

            ImageView imagev = (ImageView) findViewById(R.id.imageView3);

            imagev.setImageBitmap(imageBitmap);

            new getPictureClass().execute(imageBitmap);

        }
    }

    public void useImage(View view){

        try
        {
            TextView newtext = (TextView) findViewById(R.id.textView2);
            String foodName = newtext.getText().toString();

            Intent k = new Intent(ChooseImage.this, Nutrition.class);
            k.putExtra("foodName", foodName);
            for (int i=0; i<5; i++){
                k.putExtra("l" + i, sVals[i]);
            }
            startActivity(k);
        }catch(Exception e){

        }

    }

    public void connect(View view){


        new UpdateData().execute(1);
    }


    private class getPictureClass extends AsyncTask<Bitmap, Integer, String> {
        protected String doInBackground(Bitmap... ur) {

            File filesDir = getApplicationContext().getFilesDir();
            File imageFile = new File(filesDir, "test" + ".jpg");

            OutputStream os;
            try {
                os = new FileOutputStream(imageFile);
                ur[0].compress(Bitmap.CompressFormat.JPEG, 100, os);
                os.flush();
                os.close();
            } catch (Exception e) {

            }

            VisualRecognition service = new VisualRecognition(VisualRecognition.VERSION_DATE_2016_05_20);
            service.setApiKey("648cff685768fe2ce2c076a2290d104ceff3e6d7");

            System.out.println("Classify an image");
            ClassifyImagesOptions options = new ClassifyImagesOptions.Builder()
                    .images(imageFile)
                    .build();
            VisualClassification result = service.classify(options).execute();
            System.out.println(result);

            try {
                JSONObject jTok = (JSONObject) new JSONTokener(result.toString()).nextValue();
                JSONArray jArr  = jTok.getJSONArray("images");
                jArr  = jArr.getJSONObject(0).getJSONArray("classifiers");
                jArr  = jArr.getJSONObject(0).getJSONArray("classes");
                String objectClass = jArr.getJSONObject(0).getString("class");
                return objectClass;
            } catch (JSONException e) {
                return " - ";
            }
        }

        protected void onProgressUpdate(Integer... progress) {

        }

        protected void onPostExecute(String result) {


            TextView newtext = (TextView) findViewById(R.id.textView2);
            newtext.setText(result);

            Button btn = (Button) findViewById(R.id.button4);
            btn.setEnabled(true);

            TextView newtext3 = (TextView) findViewById(R.id.textView3);
            newtext3.setText("Click \"Use Image\" if classification is correct, otherwise take another photo.");

        }
    }

    private class UpdateData extends AsyncTask<Integer, Integer, Boolean> {
        protected Boolean doInBackground(Integer... ur) {

            Calendar cal = Calendar.getInstance();
            Date now = new Date();
            cal.setTime(now);
            long endTime = cal.getTimeInMillis();
            cal.add(Calendar.HOUR_OF_DAY, -1);
            long startTime = cal.getTimeInMillis();

            DataSource nutritionSource = new DataSource.Builder()
                    .setName("Banana")
                    .setDataType(DataType.TYPE_NUTRITION)
                    .setType(DataSource.TYPE_RAW)
                    .build();

            DataPoint banana = DataPoint.create(nutritionSource);
            banana.setTimestamp(System.currentTimeMillis(), TimeUnit.MILLISECONDS);
            banana.setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS);
            banana.getValue(Field.FIELD_FOOD_ITEM).setString("banana");
            banana.getValue(Field.FIELD_MEAL_TYPE).setInt(Field.MEAL_TYPE_SNACK);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_TOTAL_FAT, 0.4f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_SODIUM, 1f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_SATURATED_FAT, 0.1f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_PROTEIN, 1.3f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_TOTAL_CARBS, 27.0f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_CHOLESTEROL, 0.0f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_CALORIES, 105.0f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_SUGAR, 14.0f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_DIETARY_FIBER, 3.1f);
            banana.getValue(Field.FIELD_NUTRIENTS).setKeyValue(Field.NUTRIENT_POTASSIUM, 422f);

            DataSet dataSet = DataSet.create(nutritionSource);
            dataSet.add(banana);

            DataUpdateRequest updateRequest = new DataUpdateRequest.Builder().setDataSet(dataSet).setTimeInterval(startTime, endTime, TimeUnit.MILLISECONDS).build();

            Fitness.HistoryApi.updateData(apiClient, updateRequest).await(1, TimeUnit.MINUTES);
            return true;
        }

        protected void onProgressUpdate(Integer... progress) {

        }

        protected void onPostExecute(boolean result) {



        }
    }

}
