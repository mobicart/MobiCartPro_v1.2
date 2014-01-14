package com.mobicart.renamed_package;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.Selection;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

import com.mobicart.android.core.MobicartUrlConstants;
import com.mobicart.android.model.MobicartCommonData;
import com.mobicart.android.model.ProductVO;
import com.mobicart.renamed_package.R;
import com.mobicart.renamed_package.utils.CartItemCount;
import com.mobicart.renamed_package.utils.LocalSearchEtTextWatcher;
import com.mobicart.renamed_package.utils.MyCommonView;
import com.mobicart.renamed_package.utils.AsyncTasks.GetProductsTask;
import com.mobicart.renamed_package.utils.adapters.DepartmentsListAdapter;

/**
 * This activity class is used for displaying list of products in a store with
 * price and status.
 * 
 * @author mobicart
 * 
 */
public class ProductsListAct extends Activity implements
		OnCheckedChangeListener, OnClickListener, OnEditorActionListener,
		OnItemClickListener, OnKeyListener {

	public static boolean isOrderForward = false;
	public static ListView productLV;
	private RadioGroup radioGroup;
	private RadioButton priceRB, statusRB, atozRB;
	public static int sortOption;
	private MyCommonView searchBtn, backBtn, listTitleTV, cartBtn, cartEditBtn;
	private TextView loadProductsTV;
	private EditText searchTextET;
	private ArrayList<ProductVO> listToSort = new ArrayList<ProductVO>();
	private int currentPosition;
	private RelativeLayout productList_top_RL;
	public static LinearLayout loadMoreProductsLL;
	public static int currentDepartmentId;
	public static boolean isInSearchMode = false;
	private InputMethodManager imm;
	private int IsFrom;
	public static int productCount;
	private long categoryId;
	private GetProductsTask productsTask;
	@SuppressLint("ParserError")
	public static boolean isFirstLoad = true, isLoadProducts = false;
	public static int startIdx = 0, endIdx = 0, maxRows =10;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.product_list_layout);
		initializeControls();
		sortOption=1;
		imm = (InputMethodManager) this
				.getSystemService(Context.INPUT_METHOD_SERVICE);

		IsFrom = getIntent().getIntExtra("IsFrom", -1);
		startIdx = 0;
		maxRows=SplashAct.screenHeight>1000?30:10;
		endIdx=maxRows;
		switch (IsFrom) {
		case StoreTabAct.CATEGORY:
		case StoreTabAct.SUBCATEGORY:
		case StoreTabAct.DEPARTMENTS:
			currentDepartmentId = getIntent().getIntExtra("departmentId", -1);
			categoryId = getIntent().getLongExtra("categoryId", -1);
			productCount = getIntent().getIntExtra("productCount", 0);
			productsTask = new GetProductsTask(this.getParent(), productLV,
					StoreTabGroupAct.TYPE_PRODUCTS, currentDepartmentId,
					categoryId, StoreTabAct.CATEGORY, startIdx, endIdx);
			productsTask.execute("");
			break;
		case 1:
			currentDepartmentId = getIntent().getIntExtra("departmentId", -1);
			productsTask = new GetProductsTask(this.getParent(), productLV,
					StoreTabGroupAct.TYPE_PRODUCTS,IsFrom,startIdx,endIdx);
			productsTask.execute("");
			break;
		default:
			break;
		}
		searchTextET = (EditText) findViewById(R.id.productList_search_et);
		searchBtn.setOnClickListener(this);
		searchTextET.setOnEditorActionListener(this);
		productLV.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, final View arg1, int arg2,
					long arg3) {
				currentPosition = arg2;
				final int i=(Integer) arg1.getTag();
				final ProgressDialog dialog=ProgressDialog.show(ProductsListAct.this.getParent(), null, MobicartCommonData.keyValues.getString(
					      "key.iphone.LoaderText", "Loading..."));
					    Handler handler=new Handler();
					    handler.postDelayed(new Runnable() {
					     
					     @Override
					     public void run() {
					         	 StoreTabGroupAct parentActivity = (StoreTabGroupAct) getParent();
								Intent intent = new Intent(getApplicationContext(),
										ProductDetailAct.class);
								intent.putExtra("productId", i);
								intent.putExtra("currentProductPosition", currentPosition);
								parentActivity.startChildActivity("ProductDetailAct", intent);
					      dialog.cancel();
					     }
					    },1000);
			/*	StoreTabGroupAct parentActivity = (StoreTabGroupAct) getParent();
				Intent intent = new Intent(getApplicationContext(),
						ProductDetailAct.class);
				intent.putExtra("productId", (Integer) arg1.getTag());
				intent.putExtra("currentProductPosition", currentPosition);
				parentActivity.startChildActivity("ProductDetailAct", intent);*/
			}
		});
		backBtn.setOnClickListener(this);
		radioGroup.setOnCheckedChangeListener(this);
		sortingByPrice();
		searchTextET.addTextChangedListener(new LocalSearchEtTextWatcher(this,
				productLV, listToSort));
		searchTextET.setOnKeyListener(this);
		productLV.setTextFilterEnabled(true);
		productLV.setClickable(true);
	}

	/**
	 * This method is called in onCreate() to link the views declared in xml to
	 * the view variables in activity.
	 */
	private void initializeControls() {
		searchTextET = (EditText) findViewById(R.id.productList_search_et);
		searchBtn = (MyCommonView) findViewById(R.id.productList_search_button);
		productLV = (ListView) findViewById(R.id.productList_List_LV);
		listTitleTV = (MyCommonView) findViewById(R.id.productList_title_TV);
		loadProductsTV=(TextView)findViewById(R.id.loadMoreProducts_TV);
		radioGroup = (RadioGroup) findViewById(R.id.productList_RadioGroup1);
		priceRB = (RadioButton) findViewById(R.id.productList_price_RBtn);
		statusRB = (RadioButton) findViewById(R.id.productList_status_RBtn);
		atozRB = (RadioButton) findViewById(R.id.productList_AtoZ_RBtn);
		loadMoreProductsLL = (LinearLayout) findViewById(R.id.productList_bottom_bar_LL);
		backBtn = TabHostAct.prepareSoftBackButton(this);
		cartEditBtn = TabHostAct.prepareCartButton(this);
		cartEditBtn.setVisibility(View.GONE);
		loadMoreProductsLL.setVisibility(View.GONE);
		
		loadProductsTV.setTextColor(Color.parseColor("#"
				+ MobicartCommonData.colorSchemeObj.getHeaderColor()));
		priceRB.setText(MobicartCommonData.keyValues.getString(
				"key.iphone.productlist.price", "Price"));
		atozRB.setText(MobicartCommonData.keyValues.getString(
				"key.iphone.productlist.atoz", "A TO Z"));
		statusRB.setText(MobicartCommonData.keyValues.getString(
				"key.iphone.productlist.status", "Status"));
		searchTextET.setHint(MobicartCommonData.keyValues.getString(
				"key.iphone.common.search", "Enter Keyword To Search"));
		listTitleTV.setText(MobicartCommonData.keyValues.getString(
				"key.iphone.productlist.sortby", "Sort By") + ": ");
		productList_top_RL = (RelativeLayout) findViewById(R.id.productList_Top_RL);
		cartBtn = TabHostAct.prepareCartButton(this);
		cartBtn.setVisibility(View.VISIBLE);
		cartBtn.setBackgroundResource(R.drawable.cart_icon_selector);
		cartBtn.setOnClickListener(this);
		loadMoreProductsLL.setOnClickListener(this);
		if (MobicartUrlConstants.resolution == 3) {
			cartBtn.setPadding(0, 4, 12, 0);
		} else {
			cartBtn.setPadding(0, 8, 23, 0);
		}
		cartBtn.setText("" + CartItemCount.getCartCount(this));
		try {
			if (MobicartCommonData.colorSchemeObj.getSearchColor()
					.equalsIgnoreCase(null)
					|| MobicartCommonData.colorSchemeObj.getSearchColor()
							.equalsIgnoreCase("")) {
			} else {
				productList_top_RL.setBackgroundColor(Color.parseColor("#"
						+ MobicartCommonData.colorSchemeObj.getSearchColor()));
			}
		} catch (Exception e) {
		}
		backBtn.setOnClickListener(this);
		searchTextET.setOnClickListener(this);
		searchBtn.setText(" "
				+ MobicartCommonData.keyValues.getString("key.iphone.cancel",
						"Cancel") + " ");
	}

	@Override
	protected void onStart() {
		super.onStart();
	}

	@Override
	protected void onResume() {
		StoreTabGroupAct.FLAG_BACK_KEY = false;
		cartBtn.setText("" + CartItemCount.getCartCount(this));
		changeSearchBarAppearance(true);
		backBtn.setVisibility(View.VISIBLE);
		if (IsFrom == 1) {
			backBtn.setText(MobicartCommonData.keyValues.getString(
					"key.iphone.tabbar.home", "Home"));
		} else {
			backBtn.setText(MobicartCommonData.keyValues.getString(
					"key.iphone.department.store", "Store"));
		}
		backBtn.setOnClickListener(this);
		super.onResume();
	}

	@Override
	protected void onPause() {
		MobicartCommonData.isFromStart = "NotSplash";
		backBtn.setVisibility(View.VISIBLE);
		backBtn.setOnClickListener(this);
		if (IsFrom == 1) {
			backBtn.setText(MobicartCommonData.keyValues.getString(
					"key.iphone.tabbar.home", "Home"));
		} else {
			backBtn.setText(MobicartCommonData.keyValues.getString(
					"key.iphone.department.store", "Store"));
		}
		SharedPreferences prefs = getSharedPreferences("X", MODE_PRIVATE);
		Editor editor = prefs.edit();
		editor.putString("lastActivity", getClass().getName());
		editor.commit();
		super.onPause();
	}

	@Override
	protected void onStop() {
		sortingByPrice();
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		StoreTabGroupAct.FLAG_BACK_KEY = false;
		MobicartCommonData.isFromStart = "NotSplash";
		if (IsFrom==StoreTabAct.DEPARTMENTS) {
			backBtn.setVisibility(View.INVISIBLE);
		} else {
			backBtn.setVisibility(View.VISIBLE);
			backBtn.setText(MobicartCommonData.keyValues.getString(
					"key.iphone.department.store", "Store"));
		}
		super.onDestroy();
	}

	/**
	 * This Method is used to sort the products listing by price.
	 */
	private void sortingByPrice() {
		if (!isInSearchMode) {
			listToSort = MobicartCommonData.productsList;
			sortPrice(listToSort);
		} else {
			Object[] listToSort1 = LocalSearchEtTextWatcher.searchedList;
			ArrayList<ProductVO> tempSort = new ArrayList<ProductVO>();
			for (int i = 0; i < listToSort1.length; i++) {
				tempSort.add((ProductVO) listToSort1[i]);
			}
			sortPrice(tempSort);
		}
	}

	private void sortPrice(ArrayList<ProductVO> listToSort2) {
		Collections.sort(listToSort2, new Comparator<ProductVO>() {
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
		productLV.setAdapter(new DepartmentsListAdapter(ProductsListAct.this,
				StoreTabGroupAct.TYPE_PRODUCTS, listToSort2
						.toArray(new ProductVO[] {})));
	}

	/**
	 * This Method is used to sort the products listing Alphabetically.
	 */
	private void sortingAlphabetically() {
		sortingByPrice();
		if (!isInSearchMode) {
			listToSort = MobicartCommonData.productsList;
			sortATOZ(listToSort);
		} else {
			Object[] listToSort1 = LocalSearchEtTextWatcher.searchedList;
			ArrayList<ProductVO> tempSort = new ArrayList<ProductVO>();
			for (int i = 0; i < listToSort1.length; i++) {
				tempSort.add((ProductVO) listToSort1[i]);
			}
			sortATOZ(tempSort);
		}
	}

	private void sortATOZ(ArrayList<ProductVO> listToSort2) {
		Collections.sort(listToSort2, new Comparator<ProductVO>() {
			@Override
			public int compare(ProductVO object1, ProductVO object2) {
				return object1.getsName().compareToIgnoreCase(
						object2.getsName());
			}
		});
		productLV.setAdapter(new DepartmentsListAdapter(ProductsListAct.this,
				StoreTabGroupAct.TYPE_PRODUCTS, listToSort2
						.toArray(new ProductVO[] {})));
	}

	/**
	 * This Method is used to sort the products listing by available status(In
	 * Stock,Sold Out,Coming Soon).
	 */
	private void sortingByStatus() {
		sortingByPrice();
		if (!isInSearchMode) {
			listToSort = MobicartCommonData.productsList;
			sortStatus(listToSort);
		} else {
			Object[] listToSort1 = LocalSearchEtTextWatcher.searchedList;
			ArrayList<ProductVO> tempSort = new ArrayList<ProductVO>();
			for (int i = 0; i < listToSort1.length; i++) {
				tempSort.add((ProductVO) listToSort1[i]);
			}
			sortStatus(tempSort);
		}
	}

	private void sortStatus(ArrayList<ProductVO> listToSort2) {
		Collections.sort(listToSort2, new Comparator<ProductVO>() {
			@Override
			public int compare(ProductVO object1, ProductVO object2) {
				return object1.getsStatus().compareTo(object2.getsStatus());
			}
		});
		productLV.setAdapter(new DepartmentsListAdapter(ProductsListAct.this,
				StoreTabGroupAct.TYPE_PRODUCTS, listToSort2
						.toArray(new ProductVO[] {})));
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.productList_bottom_bar_LL:
			startIdx = MobicartCommonData.productsList.size();
			getMoreProductsTask(
					this.getParent(),
					productLV,
					StoreTabGroupAct.TYPE_PRODUCTS,
					IsFrom == StoreTabAct.DEPARTMENTS ? 0 : currentDepartmentId,
					IsFrom == StoreTabAct.DEPARTMENTS ? currentDepartmentId
							: categoryId,
					IsFrom == StoreTabAct.DEPARTMENTS ? StoreTabAct.DEPARTMENTS
							: IsFrom == StoreTabAct.CATEGORY ? StoreTabAct.CATEGORY
									: IsFrom==StoreTabAct.SUBCATEGORY?StoreTabAct.SUBCATEGORY:1, startIdx, endIdx);
			break;
		case R.id.universal_back_btn: {
			finish();
			if (HomeTabAct.currentOrder == HomeTabAct.ORDER_PRODUCT_SEARCH) {
				HomeTabAct.currentOrder = 0;
				Object parentActivity = getParent().getParent();
				if (parentActivity instanceof TabActivity) {
					backBtn.setVisibility(View.GONE);
					((TabActivity) parentActivity).getTabHost()
							.setCurrentTab(0);
				}
			}
			break;
		}
		case R.id.productList_search_button: {
			searchTextET.setText("");
			changeSearchBarAppearance(true);
			imm.hideSoftInputFromWindow(searchTextET.getWindowToken(), 0);
			searchTextET.setHint(MobicartCommonData.keyValues.getString(
					"key.iphone.common.search", "Enter Keyword To Search"));
			break;
		}
		case R.id.productList_search_et: {

			searchTextET.setHint(MobicartCommonData.keyValues.getString(
					"key.iphone.common.search", ""));
			searchTextET.setCursorVisible(true);
			imm.showSoftInputFromInputMethod(searchTextET.getWindowToken(), 0);
			changeSearchBarAppearance(false);
			break;
		}
		case R.id.navigation_bar_cart_btn:
			StoreTabGroupAct parentActivity = (StoreTabGroupAct) getParent();
			Intent cartAct = new Intent(this, CartAct.class);
			String backBtn = MobicartCommonData.keyValues.getString(
					"key.iphone.home.back", "Back");
			cartAct.putExtra("IsFrom", backBtn);
			cartAct.putExtra("ParentAct", "2");
			parentActivity.startChildActivity("CartAct", cartAct);
			break;
		}
	}

	private void getMoreProductsTask(Activity parent, ListView productLV2,
			int typeProducts, int currentDepartmentId2, long categoryId2,
			int i, int startIdx2, int endIdx2) {
		isFirstLoad = false;
		productsTask = new GetProductsTask(this.getParent(), productLV,
				StoreTabGroupAct.TYPE_PRODUCTS, currentDepartmentId2,
				categoryId2, i, startIdx, endIdx, isFirstLoad);
		productsTask.execute("");
	}

	/**
	 * This method is used for changing background of Search bar with cancel or
	 * Without cancel button.
	 * 
	 * @param expand
	 */
	private void changeSearchBarAppearance(boolean expand) {
		if (expand) {
			searchTextET.setText("");
			searchTextET.setHint(MobicartCommonData.keyValues.getString(
					"key.iphone.common.search", "Enter Keyword To Search"));
			searchTextET.setBackgroundResource(R.drawable.search_bar_dpi);
			searchBtn.setVisibility(View.GONE);
			searchTextET.setCursorVisible(false);
			isInSearchMode = false;
		} else {
			searchTextET.setHint("");
			searchTextET
					.setBackgroundResource(R.drawable.search_bar_withoutbtn_dpi);
			searchTextET.setCursorVisible(true);
			searchBtn.setVisibility(View.VISIBLE);
			isInSearchMode = true;
		}
	}

	@Override
	public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
		imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
		if (actionId == EditorInfo.IME_ACTION_SEARCH) {
			imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
			return true;
		}
		searchTextET.setBackgroundResource(R.drawable.search_bar_dpi);
		searchTextET.setText("");
		searchBtn.setVisibility(View.GONE);
		searchTextET.setHint(MobicartCommonData.keyValues.getString(
				"key.iphone.common.search", "Enter Keyword To Search"));
		productLV.setAdapter(new DepartmentsListAdapter(ProductsListAct.this,
				StoreTabGroupAct.TYPE_PRODUCTS));
		return false;
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		currentPosition = arg2;
		Log.e("TAG", "pos:"+currentPosition);
		StoreTabGroupAct parentActivity = (StoreTabGroupAct) getParent();
		Intent intent = new Intent(getApplicationContext(),
				ProductDetailAct.class);
		parentActivity.startChildActivity("ProductDetailAct", intent);
	}

	@Override
	public boolean onKey(View v, int keyCode, KeyEvent event) {
		if (event.getAction() != KeyEvent.ACTION_DOWN)
			return true;

		switch (keyCode) {
		case KeyEvent.KEYCODE_BACK:
			searchTextET.setBackgroundResource(R.drawable.search_bar_dpi);
			searchTextET.setHint(MobicartCommonData.keyValues.getString(
					"key.iphone.common.search", "Enter Keyword To Search"));
			searchBtn.setVisibility(View.GONE);
			break;
		case KeyEvent.KEYCODE_DEL:
			if (searchTextET.getText().toString().length() > 0) {
				searchTextET
						.setText(searchTextET
								.getText()
								.toString()
								.substring(
										0,
										searchTextET.getText().toString()
												.length() - 1));
				Editable etext = searchTextET.getText();
				Selection.setSelection(etext, searchTextET.getText().toString()
						.length());
			} else {
				searchTextET.setText("");
				searchTextET.setHint(MobicartCommonData.keyValues.getString(
						"key.iphone.common.search", "Enter Keyword To Search"));
			}
			break;
		}
		return true;
	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		switch (checkedId) {
		case R.id.productList_price_RBtn:
			sortOption=1;
			sortingByPrice();
			break;
		case R.id.productList_status_RBtn:
			sortOption=2;
			try {
				sortingByStatus();
			} catch (Exception e) {
			}
			break;
		case R.id.productList_AtoZ_RBtn:
			sortOption=3;
			try{
			sortingAlphabetically();
			}
			catch (Exception e) {
			}
			break;
		default:
			break;
		}
	}
}
