package com.mobicart.renamed_package.Paypal;

import java.io.Serializable;

import com.mobicart.renamed_package.CheckoutAct;
import com.paypal.android.MEP.PayPalResultDelegate;

/**
 * This Class gives Notification that the payment has been completed
 * successfully or not.
 * 
 * @author yogesh.kumar
 * 
 */
public class ResultDelegate implements PayPalResultDelegate, Serializable {
	private static final long serialVersionUID = 10001L;

	/**
	 * Notification that the payment has been completed successfully.
	 * 
	 * @param payKey
	 *            the pay key for the payment
	 * @param paymentStatus
	 *            the status of the transaction
	 */
	public void onPaymentSucceeded(String payKey, String paymentStatus) {
		CheckoutAct.resultTitle = "SUCCESS";
		CheckoutAct.resultInfo = "You have successfully completed your transaction.";
		CheckoutAct.resultExtra = "Key: " + payKey;
	}

	/**
	 * Notification that the payment has failed.
	 * 
	 * @param paymentStatus
	 *            the status of the transaction
	 * @param correlationID
	 *            the correlationID for the transaction failure
	 * @param payKey
	 *            the pay key for the payment
	 * @param errorID
	 *            the ID of the error that occurred
	 * @param errorMessage
	 *            the error message for the error that occurred
	 */
	public void onPaymentFailed(String paymentStatus, String correlationID,
			String payKey, String errorID, String errorMessage) {
		CheckoutAct.resultTitle = "FAILURE";
		CheckoutAct.resultInfo = errorMessage;
		CheckoutAct.resultExtra = "Error ID: " + errorID + "\nCorrelation ID: "
				+ correlationID + "\nPay Key: " + payKey;
	}

	/**
	 * Notification that the payment was canceled.
	 * 
	 * @param paymentStatus
	 *            the status of the transaction
	 */
	public void onPaymentCanceled(String paymentStatus) {
		CheckoutAct.resultTitle = "CANCELED";
		CheckoutAct.resultInfo = "The transaction has been cancelled.";
		CheckoutAct.resultExtra = "";
	}
}