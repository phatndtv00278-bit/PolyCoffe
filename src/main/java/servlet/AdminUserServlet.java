package servlet;

import dao.UserDAO;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import util.AuthUtil;
import util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    private boolean checkAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!AuthUtil.isLogin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }

        if (!AuthUtil.isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/access-denied.jsp");
            return false;
        }

        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAdmin(req, resp)) return;

        String action = ParamUtil.getString(req, "action", "list");

        if ("edit".equalsIgnoreCase(action)) {
            int id = ParamUtil.getInt(req, "id", -1);
            if (id > 0) {
                User user = userDAO.findById(id);
                req.setAttribute("editUser", user);
            }
        }

        List<User> users = userDAO.findAll();
        req.setAttribute("users", users);
        req.getRequestDispatcher("/admin-user.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAdmin(req, resp)) return;

        String action = ParamUtil.getString(req, "action", "");

        if ("create".equalsIgnoreCase(action)) {
            createUser(req);
        } else if ("update".equalsIgnoreCase(action)) {
            updateUser(req);
        } else if ("delete".equalsIgnoreCase(action)) {
            deleteUser(req);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }

    private void createUser(HttpServletRequest req) {
        String fullName = ParamUtil.getString(req, "fullName", "");
        String email = ParamUtil.getString(req, "email", "");
        String username = ParamUtil.getString(req, "username", "");
        String password = ParamUtil.getString(req, "password", "");
        String role = ParamUtil.getString(req, "role", "user");

        if (fullName.isBlank() || email.isBlank() || username.isBlank() || password.isBlank() || role.isBlank()) return;
        if (userDAO.existsByUsernameOrEmail(username, email)) return;

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setUsername(username);
        user.setPassword(hashedPassword);
        user.setRole(role);

        userDAO.insert(user);
    }

    private void updateUser(HttpServletRequest req) {
        int id = ParamUtil.getInt(req, "id", -1);
        if (id <= 0) return;

        String fullName = ParamUtil.getString(req, "fullName", "");
        String email = ParamUtil.getString(req, "email", "");
        String username = ParamUtil.getString(req, "username", "");
        String password = ParamUtil.getString(req, "password", "");
        String role = ParamUtil.getString(req, "role", "user");

        User oldUser = userDAO.findById(id);
        if (oldUser == null) return;

        User user = new User();
        user.setId(id);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setUsername(username);
        user.setRole(role);

        if (!password.isBlank()) {
            user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
            userDAO.updateWithPassword(user);
        } else {
            user.setPassword(oldUser.getPassword());
            userDAO.update(user);
        }
    }

    private void deleteUser(HttpServletRequest req) {
        int id = ParamUtil.getInt(req, "id", -1);
        if (id <= 0) return;
        userDAO.delete(id);
    }
}