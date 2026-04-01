package util;

import jakarta.servlet.http.HttpServletRequest;

public class ParamUtil {

    public static String getString(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        if (value == null) {
            return defaultValue;
        }

        value = value.trim();
        return value.isEmpty() ? defaultValue : value;
    }

    public static int getInt(HttpServletRequest request, String name, int defaultValue) {
        try {
            return Integer.parseInt(getString(request, name, String.valueOf(defaultValue)));
        } catch (Exception e) {
            return defaultValue;
        }
    }

    public static double getDouble(HttpServletRequest request, String name, double defaultValue) {
        try {
            return Double.parseDouble(getString(request, name, String.valueOf(defaultValue)));
        } catch (Exception e) {
            return defaultValue;
        }
    }

    public static boolean getBoolean(HttpServletRequest request, String name, boolean defaultValue) {
        String value = getString(request, name, String.valueOf(defaultValue));

        return "true".equalsIgnoreCase(value)
                || "1".equals(value)
                || "on".equalsIgnoreCase(value)
                || "yes".equalsIgnoreCase(value);
    }
}