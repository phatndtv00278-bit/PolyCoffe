package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.User;

public class AuthUtil {

    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("loggedInUser");
    }

    public static boolean isLogin(HttpServletRequest request) {
        return getCurrentUser(request) != null;
    }

    public static boolean isAdmin(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    public static boolean isUser(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && "user".equalsIgnoreCase(user.getRole());
    }

    public static void logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
}