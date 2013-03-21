package com.mobicart.renamed_package.database;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Environment;
/**
 * This Class is used for moving database to SD card.
 * @author mobicart
 *
 */
public class DataBaseMoveAsyncTask extends AsyncTask<String, Void, Boolean> {
	Context context;
	
	public DataBaseMoveAsyncTask(Context context) {
		this.context = context;
	}
	// can use UI thread here
	protected void onPreExecute() {
			
	}
	// automatically done on worker thread (separate from UI thread)
	protected Boolean doInBackground(final String... args) {
		String outFileName = context.getFilesDir().getParent()
				+ "/databases/DbMobicartAndroid.sqlite";
		File dbFile = new File(outFileName);
		dbFile.mkdirs();
		File exportDir = new File(Environment.getExternalStorageDirectory(), "");
		if (!exportDir.exists()) {
			exportDir.mkdirs();
		}
		File file = new File(exportDir, dbFile.getName());
		try {
			file.createNewFile();
			this.copyFile(dbFile, file);
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}

	// can use UI thread here
	protected void onPostExecute(final Boolean success) {
	}

	void copyFile(File src, File dst) throws IOException {
		FileChannel inChannel = new FileInputStream(src).getChannel();
		FileChannel outChannel = new FileOutputStream(dst).getChannel();
		try {
			inChannel.transferTo(0, inChannel.size(), outChannel);
		} finally {
			if (inChannel != null)
				inChannel.close();
			if (outChannel != null)
				outChannel.close();
		}
	}
}
