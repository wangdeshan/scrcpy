package com.genymobile.scrcpy.util;

public final class Brightness {
	private static int GetCurrent() {
		int systemBrightness = 0;
		try {
			systemBrightness = Integer.parseInt(Settings.getValue(Settings.TABLE_SYSTEM, "screen_brightness"),10);
		} catch (SettingsException e) {
			e.printStackTrace();
		}
		Ln.i("Get Current Brightness =>" + systemBrightness);
		return systemBrightness;
	}

	private static void SetCurrent(int brightness) {
		Ln.i("Set Current Brightness =>" + brightness);
		try {
			Settings.putValue(Settings.TABLE_SYSTEM, "screen_brightness", Integer.toString(brightness));
		} catch (SettingsException e) {
			e.printStackTrace();
		}
	}
	
	public static void Tick() {
		try {
			int current = GetCurrent();
			int newval = current + 1;
			if (current >= 255)
			{
				newval = current - 1;
			}else if(current < 8)
			{
				newval = 8;
			}
			SetCurrent(newval);
			SetCurrent(current);
			Ln.i("Current Brightness =>" + current);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
}
