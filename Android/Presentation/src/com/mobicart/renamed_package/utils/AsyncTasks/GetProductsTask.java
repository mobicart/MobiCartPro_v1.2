package com.mobicart.renamed_package.utils.AsyncTasks;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;

import org.json.JSONException;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.view.View;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.mobicart.android.communication.CustomException;
import com.mobicart.android.communication.MobicartLogger;
import com.mobicart.android.core.Category;
import com.mobicart.android.core.Department;
import com.mobicart.android.core.Product;
import com.mobicart.android.model.MobicartCommonData;
import com.mobicart.android.model.ProductVO;
import com.mobicart.renamed_package.CategoryTabAct;
import com.mobicart.renamed_package.HomeTabAct;
import com.mobicart.renamed_package.ProductsListAct;
import com.mobicart.renamed_package.StoreTabAct;
import com.mobicart.renamed_package.StoreTabGroupAct;
import com.mobicart.renamed_package.utils.adapters.DepartmentsListAdapter;

/**
 * @author mobicart
 * 
 */
@SuppressLint("ParserError")
public class GetProductsTask extends AsyncTask<String, String, String> {

	private Activity activity;
	private ListView departmentsLV;
	private ProgressDialog progressDialog;
	private int type, isFrom;
	private int departmentId;
	private long categoryId;
	private ArrayList<ProductVO> listToSort = new ArrayList<ProductVO>();
	private boolean isNetworkNotAvailable = false;
	private MobicartLogger objMobicartLogger;
	private SimpleDateFormat reqDateFormat;
	private int startIdx = 0, endIdx = 0, maxRows = 4;
	private boolean isFirstLoad = true;
	private ArrayList<ProductVO> tempProductsList = new ArrayList<ProductVO>();
	

	public GetProductsTask(Activity activity, ListView departmentsLV, int type,
			int isFrom, int startIdx2, int endIdx2) {
		this.activity = activity;
		this.departmentsLV = departmentsLV;
		this.type = type;
		this.isFrom = isFrom;
		this.startIdx = startIdx2;
		this.endIdx = endIdx2;
		progressDialog = new ProgressDialog(activity.getParent());
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.LoaderText", ""));
		progressDialog.setCancelable(false);
		reqDateFormat = new SimpleDateFormat("MMM. dd,yyyy kk:mm:ss ");
		objMobicartLogger = new MobicartLogger("MobicartServiceLogger");
	}

	public GetProductsTask(Activity activity, ListView departmentsLV, int type) {
		this.activity = activity;
		this.departmentsLV = departmentsLV;
		this.type = type;
		progressDialog = new ProgressDialog(activity.getParent());
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.LoaderText", ""));
		progressDialog.setCancelable(false);
		reqDateFormat = new SimpleDateFormat("MMM. dd,yyyy kk:mm:ss ");
		objMobicartLogger = new MobicartLogger("MobicartServiceLogger");
	}

	public GetProductsTask(Activity activity, ListView departmentsLV, int type,
			int DepartmentId, long CategoryId) {
		this.activity = activity;
		this.departmentsLV = departmentsLV;
		this.type = type;
		this.departmentId = DepartmentId;
		this.categoryId = CategoryId;
		progressDialog = new ProgressDialog(activity.getParent());
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.LoaderText", ""));
		progressDialog.setCancelable(false);
	}

	public GetProductsTask(Activity activity, ListView departmentsLV, int type,
			int DepartmentId, long CategoryId, int isFrom, int startIdx,
			int endIdx) {
		this.activity = activity;
		this.departmentsLV = departmentsLV;
		this.type = type;
		this.isFrom = isFrom;
		this.departmentId = DepartmentId;
		this.categoryId = CategoryId;
		this.startIdx = startIdx;
		this.endIdx = endIdx;
		progressDialog = new ProgressDialog(activity.getParent());
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.LoaderText", ""));
		progressDialog.setCancelable(false);
	}

	public GetProductsTask(Activity parent, ListView productLV,
			int typeProducts, int currentDepartmentId, long categoryId2, int i,
			int startIdx2, int endIdx2, boolean isFirstLoad) {
		this.activity = parent;
		this.departmentsLV = productLV;
		this.type = typeProducts;
		this.departmentId = currentDepartmentId;
		this.categoryId = categoryId2;
		this.startIdx = startIdx2;
		this.endIdx = endIdx2;
		this.isFirstLoad = isFirstLoad;
		this.isFrom = i;
		progressDialog = new ProgressDialog(activity.getParent());
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.setMessage(MobicartCommonData.keyValues.getString(
				"key.iphone.LoaderText", ""));
		progressDialog.setCancelable(false);
	}

	@Override
	protected void onPreExecute() {
		progressDialog.show();
		super.onPreExecute();
	}

	@Override
	protected String doInBackground(String... urls) {
		if (type == StoreTabGroupAct.TYPE_DEPARTMENTS) {// departments
			if (!getDepartments(getCurrentStoreId())) {
				return "FALSE";
			} else {
				return "TRUE";
			}
		} else if (type == StoreTabGroupAct.TYPE_CATEGORIES) {
			if (!getCategories(getCurrentStoreId(),
					(int) CategoryTabAct.currentDepartmentId)) {
				return "FALSE";
			} else {
				return "TRUE";
			}

		} else if (type == StoreTabGroupAct.TYPE_SUBCATEGORIES) {
			if (!getSubCategories(departmentId, categoryId)) {
				return "FALSE";
			} else {
				return "TRUE";
			}
		} else if (type == StoreTabGroupAct.TYPE_PRODUCTS) {
			if (HomeTabAct.currentOrder == HomeTabAct.ORDER_PRODUCT_SEARCH) {
				globalSearch(HomeTabAct.searchQuery);
				return "TRUE";
			} else {
				if (isFrom == StoreTabAct.CATEGORY
						|| isFrom == StoreTabAct.DEPARTMENTS
						|| isFrom == StoreTabAct.SUBCATEGORY) {
					if (!getProducts(getCurrentStoreId(), departmentId,
							(int) categoryId, startIdx, endIdx)) {
						return "FALSE";
					} else {
						return "TRUE";
					}
				} 
			}
		}
		return "FALSE";
	}

	private boolean getSubCategories(int departmentId2, long categoryId2) {
		Category category = new Category();
		try {
			MobicartCommonData.subCategoriesList = category.getSubCategory(
					activity, getCurrentStoreId(), (int) categoryId2);
			return true;
		} catch (NullPointerException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			return false;
		} catch (JSONException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			return false;
		} catch (CustomException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			isNetworkNotAvailable = true;
			return false;
		}
	}

	@Override
	protected void onPostExecute(String result) {
		if (result.equalsIgnoreCase("FALSE")) {
			if (isNetworkNotAvailable)
				showNetworkError();
			else
				showServerError();
		} else {

			if (type == StoreTabGroupAct.TYPE_CATEGORIES
					|| type == StoreTabGroupAct.TYPE_DEPARTMENTS) {
				departmentsLV.setAdapter(new DepartmentsListAdapter(activity,
						type));
			}
			if (type == StoreTabGroupAct.TYPE_SUBCATEGORIES) {
				departmentsLV.setAdapter(new DepartmentsListAdapter(activity,
						type));
			}
			if (type == StoreTabGroupAct.TYPE_PRODUCTS) {
				if (!isFirstLoad) {
					if (departmentsLV != null) {
						((BaseAdapter) departmentsLV.getAdapter())
								.notifyDataSetChanged();
						ProductsListAct.loadMoreProductsLL
								.setVisibility(View.GONE);
						// departmentsLV.invalidateViews();
					}
				} else {
					sortingByPrice();
					departmentsLV.setAdapter(new DepartmentsListAdapter(
							activity, StoreTabGroupAct.TYPE_PRODUCTS,
							listToSort.toArray(new ProductVO[] {})));
				}
			}
		}
		try {
			progressDialog.dismiss();
			progressDialog = null;
		} catch (Exception e) {
		}
		super.onPostExecute(result);
	}

	private void showNetworkError() {
		AlertDialog alertDialog = new AlertDialog.Builder(
				this.activity.getParent()).create();
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
						activity.getParent().startActivity(intent);
						activity.getParent().finish();
					}
				});
		alertDialog.show();
	}

	private void showServerError() {
		final AlertDialog alertDialog = new AlertDialog.Builder(
				this.activity.getParent()).create();
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

	private Boolean getDepartments(int storeId) {
		Department department = new Department();
		try {
			MobicartCommonData.departmentsList = department
					.getStoreDepartments(activity,
							MobicartCommonData.appIdentifierObj.getStoreId());
			return true;
		} catch (NullPointerException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			return false;
		} catch (JSONException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			return false;
		} catch (CustomException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			isNetworkNotAvailable = true;
			return false;
		}
	}

	private boolean getCategories(int storeId, int departmentId) {

		Category category = new Category();
		try {
			MobicartCommonData.categoriesList = category
					.getStoreSubDepartments(activity, storeId, departmentId);
			return true;
		} catch (NullPointerException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			return false;
		} catch (JSONException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			return false;
		} catch (CustomException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			isNetworkNotAvailable = true;
			return false;
		}
	}

	private boolean getProducts(int storeId, int departmentId, int categoryId,
			int startIdx2, int endIdx2) {
		Product product = new Product();
		try {
			Context context = activity;
			tempProductsList = product
					.getCategoryProductsWithPaginationFromSubDepartment(
							context,
							MobicartCommonData.appIdentifierObj.getUserId(),
							storeId, departmentId, categoryId,
							MobicartCommonData.territoryId,
							MobicartCommonData.stateId, startIdx2, endIdx2);
			if (MobicartCommonData.productsList.size() != maxRows) {
				maxRows = MobicartCommonData.productsList.size();
			}
			if (!isFirstLoad) {
				MobicartCommonData.productsList.addAll(tempProductsList);
			} else {
				MobicartCommonData.productsList.clear();
				MobicartCommonData.productsList = tempProductsList;
			}
			return true;
		} catch (JSONException e) {
			return false;
		} catch (NullPointerException e) {
			return false;
		} catch (CustomException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
			isNetworkNotAvailable = true;
			return false;
		}
	}

	private int getCurrentStoreId() {
		return MobicartCommonData.appIdentifierObj.getStoreId();
	}

	private void globalSearch(String query) {

		Product product = new Product();
		try {
			tempProductsList = product.getproductsBySearchWithCountryAndState(
					activity, MobicartCommonData.appIdentifierObj.getStoreId(),
					query, departmentId, MobicartCommonData.territoryId,
					MobicartCommonData.stateId, startIdx, endIdx);
			ProductsListAct.productCount = tempProductsList.size() > 0 ? tempProductsList
					.get(0).getAppId() : 0;
			if (MobicartCommonData.productsList.size() != maxRows) {
				maxRows = MobicartCommonData.productsList.size();
			}
			if (!isFirstLoad) {
				MobicartCommonData.productsList.addAll(tempProductsList);
			} else {
				MobicartCommonData.productsList.clear();
				MobicartCommonData.productsList = tempProductsList;
			}
		} catch (JSONException e) {
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
		} catch (NullPointerException e) {
			e.printStackTrace();
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
		} catch (CustomException e) {
			isNetworkNotAvailable = true;
			objMobicartLogger.LogExceptionMsg(reqDateFormat.format(new Date()),
					e.getMessage());
		}
	}

	private void sortingByPrice() {
		listToSort = MobicartCommonData.productsList;
		if (listToSort.size() > 0) {
			Collections.sort(listToSort, new Comparator<ProductVO>() {
				@Override
				public int compare(ProductVO object1, ProductVO object2) {
					float price1 = (float) object1.getfPrice();
					float price2 = (float) object2.getfPrice();
					if (price1 > price2) {
						return 1;
					} else if (price1 < price2) {
						return -1;
					} else {
						return 0;
					}
				}
			});
		}
	}
}
