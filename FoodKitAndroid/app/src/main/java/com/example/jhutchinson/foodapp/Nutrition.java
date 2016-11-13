package com.example.jhutchinson.foodapp;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.ibm.watson.developer_cloud.android.library.audio.StreamPlayer;
import com.ibm.watson.developer_cloud.text_to_speech.v1.TextToSpeech;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;

public class Nutrition extends AppCompatActivity {

    public  String[] sVals = new String[5];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.nutrition);

        Bundle intent = this.getIntent().getExtras();

        if (!intent.getString("l0").isEmpty()) {
            for (int i=0; i<5; i++){
                sVals[i] = intent.getString("l" + i);
            }
        }

        intent = this.getIntent().getExtras();
        String foodName = intent.getString("foodName");

        TextView newtext = (TextView) findViewById(R.id.textView);
        newtext.setText(foodName);

        new getFoodData().execute(foodName);

    }

    public void goBack(View view){
        try
        {
            Intent k = new Intent(Nutrition.this, ChooseImage.class);
            for (int i=0; i<5; i++){
                k.putExtra("l" + i, sVals[i]);
            }
            startActivity(k);
        }catch(Exception e){

        }
    }

    public void submitFood(View view){
        try
        {
            TextView newtext = (TextView) findViewById(R.id.textView);
            String foodName = newtext.getText().toString();

            Intent k = new Intent(Nutrition.this, Overview.class);
            for (int i=0; i<5; i++){
                if (sVals[i] != " "){
                    sVals[i] = foodName;
                    break;
                }
            }
            startActivity(k);
        }catch(Exception e){

        }
    }

    private class getFoodData extends AsyncTask<String, Integer, String> {
        protected String doInBackground(String... food) {

            ConnectivityManager connMgr = (ConnectivityManager)
                    getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
            if (networkInfo != null && networkInfo.isConnected()) {

                try {

                    String foodenc = URLEncoder.encode(food[0], "UTF-8");

                    URL url = new URL("https://api.nutritionix.com/v1_1/search/" + foodenc+ "?fields=item_name%2Cnf_calories%2Cnf_total_fat%2Cnf_cholesterol%2Cnf_sodium%2Cnf_total_carbohydrate%2Cnf_protein&appId=0ade1c44&appKey=627c35258c036c37885553d8714be8e4");
                    HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                    try {
                        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
                        StringBuilder stringBuilder = new StringBuilder();
                        String line;
                        while ((line = bufferedReader.readLine()) != null) {
                            stringBuilder.append(line).append("\n");
                        }
                        bufferedReader.close();
                        return stringBuilder.toString();
                    } finally {
                        urlConnection.disconnect();
                    }
                } catch (MalformedURLException e) {
                    return null;
                } catch (IOException e) {
                    return null;
                }

            } else {
                return null;
            }
        }

        protected void onProgressUpdate(Integer... progress) {

        }

        protected void onPostExecute(String result) {

            TextView newtext = (TextView) findViewById(R.id.textView);
//            newtext.setText(result);

            System.out.println(result);

            try{
                JSONObject jTok = (JSONObject) new JSONTokener(result).nextValue();
                JSONArray jArr  = jTok.getJSONArray("hits");
//                newtext = (TextView) findViewById(R.id.TextOut);

                jTok = jArr.getJSONObject(0);

                jTok = jTok.getJSONObject("fields");

                newtext.setText("Name: " + jTok.getString("item_name") + "\nCalories: " + jTok.getString("nf_calories") + "\nTotalFat: " + jTok.getString("nf_total_fat") + "\nCholesterol: " + jTok.getString("nf_cholesterol") + "\nSodium: " + jTok.getString("nf_sodium") + "\nCarbohydrates: " + jTok.getString("nf_total_carbohydrate") + "\nProtein: " + jTok.getString("nf_protein"));
//                newtext.setText(result);
            } catch (JSONException e) {
//                newtext = (TextView) findViewById(R.id.TextOut);
//                newtext.setText("Something went wrong");
                return;
            }



        }
    }
}
