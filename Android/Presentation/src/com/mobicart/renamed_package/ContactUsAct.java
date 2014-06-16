package com.mobicart.renamed_package;

//Sa Vo fix bug map not dislay. Implement map in new way, change to Google Map API v2
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.StrictMode;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.mobicart.android.core.MobicartUrlConstants;
import com.mobicart.android.model.MobicartCommonData;
import com.mobicart.android.model.UserAddressVO;
import com.mobicart.renamed_package.utils.CartItemCount;
import com.mobicart.renamed_package.utils.MyCommonView;
import com.mobicart.renamed_package.utils.AsyncTasks.GetUserAddressTask;
import com.mobicart.renamed_package.utils.AsyncTasks.GetUserAddressTask.GetUserAddressTaskDelegate;

/**
 * This Activity is used to show user address on Google Map.
 * 
 * @author mobicart
 * 
 */
public class ContactUsAct extends Activity implements OnClickListener,
		GetUserAddressTaskDelegate {

	private class GetLocationTask extends AsyncTask<String, String, String> {

		@Override
		protected String doInBackground(String... params) {
			// TODO Auto-generated method stub

			LatLng location;
			try {
				location = getLocationFromString(finalCompleteAddress);
				latitude = location.latitude;
				longitude = location.longitude;
				return "true";
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			return null;
		}

		@Override
		protected void onPostExecute(String result) {
			// TODO Auto-generated method stub
			navigateToLocation((latitude), (longitude), myMapView,
					finalCompleteAddress);
			super.onPostExecute(result);

		}

	}

	private MyCommonView TitleTV, backButton, contact_addressInfo_TV, cartBtn,
			cartEditBtn;
	private ImageView TitleImageView;
	private GoogleMap myMapView;
	private double latitude, longitude;
	private String finalCompleteAddress = "";
	private String sAddress = null;
	private String sCity = null;
	private String sState = null;
	private String sCountry = null;
	private String title;
	private String description;
	private UserAddressVO uAddVO;
	Location userLocation;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);


		setContentView(R.layout.contact_us_layout);
		Bundle extra = getIntent().getExtras();
		title = extra.getString("Title");
		description = extra.getString("Descripition");

		GetUserAddressTask userAddressTask = new GetUserAddressTask(this);
		userAddressTask.execute("");

		int TitleImage = extra.getInt("Image");

		myMapView = ((MapFragment) getFragmentManager().findFragmentById(
				R.id.contactUs_map)).getMap();

		cartEditBtn = TabHostAct.prepareCartButton(this);
		cartEditBtn.setVisibility(View.GONE);
		cartBtn = TabHostAct.prepareCartButton(this);
		cartBtn.setVisibility(View.VISIBLE);
		cartBtn.setBackgroundResource(R.drawable.cart_icon_selector);
		cartBtn.setOnClickListener(this);
		if (MobicartUrlConstants.resolution == 3) {
			cartBtn.setPadding(0, 4, 12, 0);
		} else {
			cartBtn.setPadding(0, 8, 23, 0);
		}
		cartBtn.setText("" + CartItemCount.getCartCount(this));
		TitleImageView = (ImageView) findViewById(R.id.common_nav_bar_heading_IV);
		TitleImageView.setImageDrawable(getResources().getDrawable(TitleImage));
		TitleTV = (MyCommonView) findViewById(R.id.common_nav_bar_heading_TV);
		contact_addressInfo_TV = (MyCommonView) findViewById(R.id.contact_addressInfo2_TV);

		backButton = TabHostAct.prepareSoftBackButton(this);
		backButton.setVisibility(View.VISIBLE);
		backButton.setText(MobicartCommonData.keyValues.getString(
				"key.iphone.tabbar.more", ""));
		backButton.setOnClickListener(this);
		TitleTV.setText(title);
		contact_addressInfo_TV.setText(description);
		contact_addressInfo_TV.setTextColor(Color.parseColor("#"
				+ MobicartCommonData.colorSchemeObj.getLabelColor()));

	}

	/**
	 * This Method is used to show Network related errors.
	 */
	private void showNetworkError() {
		AlertDialog alertDialog = new AlertDialog.Builder(ContactUsAct.this)
				.create();
		alertDialog.setTitle(MobicartCommonData.keyValues.getString(
				"key.iphone.nointernet.title", "Alert"));
		alertDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.nointernet.text", "Network Error"));
		alertDialog.setButton(MobicartCommonData.keyValues.getString(
				"key.iphone.nointernet.cancelbutton", "Ok"),
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						Intent intent = new Intent(Intent.ACTION_MAIN);
						intent.addCategory(Intent.CATEGORY_HOME);
						intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
						ContactUsAct.this.startActivity(intent);
						ContactUsAct.this.finish();
					}
				});
		alertDialog.show();
	}

	/**
	 * This Method is used to show Server Errors.
	 */
	private void showServerError() {
		final AlertDialog alertDialog = new AlertDialog.Builder(
				ContactUsAct.this.getParent()).create();
		alertDialog.setTitle(MobicartCommonData.keyValues.getString(
				"key.iphone.server.notresp.title.error", "Alert"));
		alertDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.server.notresp.text", "Server not Responding"));
		alertDialog.setButton(MobicartCommonData.keyValues.getString(
				"key.iphone.nointernet.cancelbutton", "OK"),
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						alertDialog.cancel();
					}
				});
		alertDialog.show();
	}

	@Override
	protected void onPause() {
		MobicartCommonData.isFromStart = "NotSplash";
		super.onPause();
	}

	/**
	 * This Method is used to navigate on address or location of user.
	 * 
	 * @param d
	 * @param e
	 * @param myMapView2
	 * @param cAddress
	 */
	private void navigateToLocation(double d, double e, GoogleMap map,
			String cAddress) {

		LatLng newLocation = new LatLng(d, e);
		myMapView.addMarker(new MarkerOptions().position(newLocation).title(
				cAddress));

		int zoom = 0;
		if (d != 0 && e != 0) {
			zoom = 15;
		}
		myMapView.animateCamera(
				CameraUpdateFactory.newLatLngZoom(newLocation, zoom), 2000,
				null);

	}

	@Override
	protected void onResume() {

		backButton.setVisibility(View.VISIBLE);
		backButton.setText(MobicartCommonData.keyValues.getString(
				"key.iphone.tabbar.more", ""));
		cartBtn.setText("" + CartItemCount.getCartCount(this));
		backButton.setOnClickListener(this);

		super.onResume();
	}

	@Override
	protected void onDestroy() {

		MobicartCommonData.isFromStart = "NotSplash";
		backButton.setVisibility(View.GONE);

		super.onDestroy();
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		float zoomLevel = myMapView.getCameraPosition().zoom;
		if (keyCode == KeyEvent.KEYCODE_I) {
			// myMapView.getController().setZoom(myMapView.getZoomLevel() + 1);
			myMapView.animateCamera(CameraUpdateFactory.zoomTo(zoomLevel + 1));
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_O) {
			// myMapView.getController().setZoom(myMapView.getZoomLevel() - 1);
			myMapView.animateCamera(CameraUpdateFactory.zoomTo(zoomLevel - 1));
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_S) {
			// myMapView.setSatellite(true);
			myMapView.setMapType(GoogleMap.MAP_TYPE_SATELLITE);
			return true;
		} else if (keyCode == KeyEvent.KEYCODE_M) {
			// myMapView.setSatellite(false);
			myMapView.setMapType(GoogleMap.MAP_TYPE_NORMAL);
			return true;
		}

		return false;
	}

	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.universal_back_btn: {
			finish();
			break;
		}
		case R.id.navigation_bar_cart_btn:
			MoreTabGroupAct parentActivity = (MoreTabGroupAct) getParent();
			Intent cartAct = new Intent(this, CartAct.class);
			String backBtn = MobicartCommonData.keyValues.getString(
					"key.iphone.more.contactus", "Contact Us");
			cartAct.putExtra("IsFrom", backBtn);
			cartAct.putExtra("ParentAct", "5");
			parentActivity.startChildActivity("CartAct", cartAct);
			break;
		}
	}

	public LatLng getLocationFromString(String address) throws JSONException {

		String encodedJson = "";
		try {
			encodedJson = URLEncoder.encode(address, "utf-8");
		} catch (UnsupportedEncodingException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		String url = "http://maps.google.com/maps/api/geocode/json?address="
				+ encodedJson + "&ka&sensor=false";
		HttpGet httpGet = new HttpGet(url);
		HttpClient client = new DefaultHttpClient();
		HttpResponse response;
		StringBuilder stringBuilder = new StringBuilder();

		try {
			response = client.execute(httpGet);
			HttpEntity entity = response.getEntity();
			InputStream stream = entity.getContent();
			int b;
			while ((b = stream.read()) != -1) {
				stringBuilder.append((char) b);
			}
		} catch (ClientProtocolException e) {
		} catch (IOException e) {
		}

		JSONObject jsonObject = new JSONObject();
		jsonObject = new JSONObject(stringBuilder.toString());

		double lng = ((JSONArray) jsonObject.get("results")).getJSONObject(0)
				.getJSONObject("geometry").getJSONObject("location")
				.getDouble("lng");

		double lat = ((JSONArray) jsonObject.get("results")).getJSONObject(0)
				.getJSONObject("geometry").getJSONObject("location")
				.getDouble("lat");

		return new LatLng(lat, lng);
	}

	public void didGetUserAddress(UserAddressVO userAddress) {
		// TODO Auto-generated method stub
		if (userAddress != null) {
			uAddVO = userAddress;
			if (uAddVO.getsAddress().equals("") || uAddVO.getsAddress() == null)
				sAddress = "";
			else
				sAddress = uAddVO.getsAddress();
			sCity = uAddVO.getsCity();
			sState = uAddVO.getsState();
			sCountry = uAddVO.getsCountry();

			finalCompleteAddress = finalCompleteAddress.concat(!sAddress
					.equals("") ? sAddress != null ? sAddress + "," : "" : "");
			finalCompleteAddress = finalCompleteAddress.concat(!sCity
					.equals("") ? sCity != null ? sCity + "," : "" : "");
			finalCompleteAddress = finalCompleteAddress.concat(!sState
					.equals("") ? sState != null ? sState + "," : "" : "");
			finalCompleteAddress = finalCompleteAddress.concat(!sCountry
					.equals("") ? sCountry != null ? sCountry : "" : "");

			GetLocationTask getLocationTask = new GetLocationTask();
			getLocationTask.execute("");

		}

	}
}
