package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.AuthUtil;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        String ctx = request.getContextPath();

        boolean publicPage =
                uri.equals(ctx + "/login") ||
                        uri.equals(ctx + "/register") ||
                        uri.equals(ctx + "/forgot-password") ||
                        uri.equals(ctx + "/reset-password") ||
                        uri.equals(ctx + "/logout") ||

                        // PayOS
                        uri.equals(ctx + "/payos-webhook") ||
                        uri.equals(ctx + "/payos-return") ||

                        uri.endsWith("/login.jsp") ||
                        uri.endsWith("/register.jsp") ||
                        uri.endsWith("/forgot-password.jsp") ||
                        uri.endsWith("/reset-password.jsp") ||
                        uri.endsWith("/access-denied.jsp") ||

                        uri.contains("/uploads/") ||
                        uri.contains(".css") ||
                        uri.contains(".js") ||
                        uri.contains(".png") ||
                        uri.contains(".jpg") ||
                        uri.contains(".jpeg") ||
                        uri.contains(".gif") ||
                        uri.contains(".webp") ||
                        uri.contains(".svg") ||
                        uri.contains(".ico");

        if (publicPage) {
            chain.doFilter(req, res);
            return;
        }

        if (!AuthUtil.isLogin(request)) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        boolean adminPage =
                uri.equals(ctx + "/admin.jsp") ||
                        uri.equals(ctx + "/admin") ||
                        uri.startsWith(ctx + "/admin/");

        if (adminPage && !AuthUtil.isAdmin(request)) {
            response.sendRedirect(ctx + "/access-denied.jsp");
            return;
        }

        chain.doFilter(req, res);
    }
}