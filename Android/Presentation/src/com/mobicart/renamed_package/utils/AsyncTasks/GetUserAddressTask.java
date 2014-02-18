package com.mobicart.renamed_package.utils.AsyncTasks;

import java.text.SimpleDateFormat;
import java.util.Currency;
import java.util.Date;

import org.json.JSONException;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;

import com.mobicart.android.communication.CustomException;
import com.mobicart.android.communication.MobicartLogger;
import com.mobicart.android.core.UserAddress;
import com.mobicart.android.model.MobicartCommonData;
import com.mobicart.android.model.UserAddressVO;
import com.mobicart.renamed_package.ChkLoginStatusAct;
import com.mobicart.renamed_package.LangPkgAct;
import com.mobicart.renamed_package.constants.MobiCartConstantIds;

/**
 * @author mobicart
 * 
 */


public class GetUserAddressTask extends AsyncTask<String, String, UserAddressVO> {
	public interface GetUserAddressTaskDelegate {
		public void didGetUserAddress(UserAddressVO userAddress);
	}
	private Activity activity;
	public static String applicationCurrency;
	public static boolean isFirstTime = true;
	
	private GetUserAddressTaskDelegate delegate;

	/**
	 * @param activity
	 * @param backgroundView
	 */
	public GetUserAddressTask(Activity activity) {
		this.activity = activity;
		delegate = (GetUserAddressTaskDelegate) activity;

	}

	@Override
	protected UserAddressVO doInBackground(String... urls) {
		UserAddressVO userAddress  = getUserAddressTask();

		return userAddress;
	}

	private UserAddressVO getUserAddressTask() {
		UserAddress uaddress = new UserAddress();
		UserAddressVO uAddVO = null;
		try {
			uAddVO = uaddress.getUserAddress(activity,
					MobiCartConstantIds.userName);
		} catch (NullPointerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (CustomException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return uAddVO;

	}

	@Override
	protected void onPostExecute(UserAddressVO result) {
		if(delegate!=null){
			delegate.didGetUserAddress(result);
		}
		super.onPostExecute(result);

		
	}

	private void showNetworkError() {
		activity.runOnUiThread(new Runnable() {

			@Override
			public void run() {
				AlertDialog alertDialog = new AlertDialog.Builder(activity)
						.create();
				alertDialog.setTitle(MobicartCommonData.keyValues.getString(
						"key.iphone.nointernet.title", "Alert"));
				alertDialog.setMessage(MobicartCommonData.keyValues.getString(
						"key.iphone.nointernet.text", "Network Error"));
				alertDialog.setButton(MobicartCommonData.keyValues.getString(
						"key.iphone.nointernet.cancelbutton", "Ok"),
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int which) {
								Intent intent = new Intent(Intent.ACTION_MAIN);
								intent.addCategory(Intent.CATEGORY_HOME);
								intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
								activity.startActivity(intent);
								activity.finish();
							}
						});
				alertDialog.show();
			}
		});

	}

	private void showServerError() {
		activity.runOnUiThread(new Runnable() {

			@Override
			public void run() {
				AlertDialog alertDialog = new AlertDialog.Builder(activity)
						.create();
				alertDialog.setTitle(MobicartCommonData.keyValues.getString(
						"key.iphone.server.notresp.title.error", "Alert"));
				alertDialog.setMessage(MobicartCommonData.keyValues.getString(
						"key.iphone.server.notresp.text",
						"Server not Responding"));
				alertDialog.setButton(MobicartCommonData.keyValues.getString(
						"key.iphone.nointernet.cancelbutton", "OK"),
						new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog,
									int which) {
								Intent intent = new Intent(Intent.ACTION_MAIN);
								intent.addCategory(Intent.CATEGORY_HOME);
								intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
								activity.startActivity(intent);
								activity.finish();
							}
						});
				alertDialog.show();
			}
		});
	}

	@Override
	protected void onProgressUpdate(String... values) {
		super.onProgressUpdate(values);
	}
}
