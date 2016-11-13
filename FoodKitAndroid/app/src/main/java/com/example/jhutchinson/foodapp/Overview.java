package com.example.jhutchinson.foodapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.content.Context;
import android.widget.ArrayAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.view.View;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.fitness.Fitness;
import com.ibm.watson.developer_cloud.text_to_speech.v1.TextToSpeech;
import com.ibm.watson.developer_cloud.android.library.audio.StreamPlayer;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.HttpURLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;


public class Overview extends AppCompatActivity {

    private GoogleApiClient apiClient;
    public  String[] sVals = new String[5];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.overview);




        Bundle intent = this.getIntent().getExtras();

        if (!(intent == null) ){
            for (int i=0; i<5; i++){
                sVals[i] = intent.getString("l" + i);
            }
        }else{
            for (int i =0; i<5; i++){
//                if (sVals[i].equals("")){
                    sVals[i] = " ";
//                }
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


        ListView newl = (ListView) findViewById(R.id.lview);

        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, android.R.id.text1, sVals);


        // Assign adapter to ListView
        newl.setAdapter(adapter);

    }

    public void addItem(View view){
        try
        {
            Intent k = new Intent(Overview.this, ChooseImage.class);
            for (int i=0; i<5; i++){
                k.putExtra("l" + i, sVals[i]);
            }

            startActivity(k);
        }catch(Exception e){

        }
    }

    public void changeDate(View view){
        try
        {
            Intent k = new Intent(Overview.this, ChooseImage.class);
            for (int i=0; i<5; i++){
                k.putExtra("l" + i, sVals[i]);
            }
            startActivity(k);
        }catch(Exception e){

        }
    }

    public void buttonClick(View view){
//        TextView newtext = (TextView) findViewById(R.id.TextOut);
//        newtext.setText("Click");

        new TalkToIBMTTS().execute(1);
    }

    public void nextScreen(View view){
        try
        {
            Intent k = new Intent(Overview.this, ChooseImage.class);
            startActivity(k);
        }catch(Exception e){

        }
    }


    private class TalkToIBMTTS extends AsyncTask<Integer, Integer, String> {
        protected String doInBackground(Integer... integer) {

            ConnectivityManager connMgr = (ConnectivityManager)
                    getSystemService(Context.CONNECTIVITY_SERVICE);
                NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
            if (networkInfo != null && networkInfo.isConnected()) {
                TextToSpeech service = new TextToSpeech();
                service.setUsernameAndPassword("fc9661bb-08e4-4de4-bd9b-80276f399a9d", "CgSgc1QsRccO");

                InputStream stream = service.synthesize("Hello World", service.getVoice("en-US_MichaelVoice").execute()).execute();

                StreamPlayer player = new StreamPlayer();
                player.playStream(stream);

                try {
                    URL url = new URL("https://api.nutritionix.com/v1_1/search/cheddar%20cheese?fields=item_name%2Cnf_calories%2Cnf_total_fat%2Cnf_cholesterol%2Cnf_sodium%2Cnf_total_carbohydrate%2Cnf_protein&appId=0ade1c44&appKey=627c35258c036c37885553d8714be8e4");
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
                } catch (IOException e){
                    return null;
                }

            } else {
                return null;
            }
        }

        protected void onProgressUpdate(Integer... progress) {

        }

        protected void onPostExecute(String result) {

//            TextView newtext = (TextView) findViewById(R.id.TextOut);
//            newtext.setText(result);

            System.out.println(result);

            try{
                JSONObject jTok = (JSONObject) new JSONTokener(result).nextValue();
                JSONArray jArr  = jTok.getJSONArray("hits");
//                newtext = (TextView) findViewById(R.id.TextOut);

                jTok = jArr.getJSONObject(0);

                jTok = jTok.getJSONObject("fields");

//                newtext.setText("Name: " + jTok.getString("item_name") + "\nCalories: " + jTok.getString("nf_calories") + "\nTotalFat: " + jTok.getString("nf_total_fat") + "\nCholesterol: " + jTok.getString("nf_cholesterol") + "\nSodium: " + jTok.getString("nf_sodium") + "\nCarbohydrates: " + jTok.getString("nf_total_carbohydrate") + "\nProtein: " + jTok.getString("nf_protein"));
//                newtext.setText(jTok.getString("item_name"));
            } catch (JSONException e) {
//                newtext = (TextView) findViewById(R.id.TextOut);
//                newtext.setText("Something went wrong");
                return;
            }



        }
    }
}

