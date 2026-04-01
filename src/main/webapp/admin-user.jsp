<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String ctx = request.getContextPath();

    User loginUser = (User) session.getAttribute("loggedInUser");
    if (loginUser == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }
    if (!"admin".equalsIgnoreCase(loginUser.getRole())) {
        response.sendRedirect(ctx + "/access-denied.jsp");
        return;
    }

    List<User> users = (List<User>) request.getAttribute("users");
    User editUser = (User) request.getAttribute("editUser");
    boolean isEdit = editUser != null;
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý tài khoản - PolyCoffee</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        :root {
            --coffee: #8a5a52;
            --coffee-dark: #6d433d;
            --coffee-soft: #b8867d;
            --text-dark: #2f2a28;
            --text-soft: #7a6d68;
            --shadow-soft: 0 10px 30px rgba(37, 24, 19, 0.10);
            --shadow-hover: 0 18px 38px rgba(37, 24, 19, 0.16);
            --radius-xl: 28px;
            --radius-lg: 22px;
            --radius-md: 16px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", Arial, sans-serif;
            background:
                radial-gradient(circle at top left, #efe4dc 0%, transparent 30%),
                radial-gradient(circle at bottom right, #ddd7d1 0%, transparent 28%),
                linear-gradient(135deg, #ece9e6 0%, #ddd8d3 100%);
            color: #fff;
        }

        .dashboard-shell {
            background: linear-gradient(135deg, rgba(113, 84, 78, 0.97), rgba(42, 39, 39, 0.97));
            min-height: calc(100vh - 24px);
            border-radius: 34px;
            overflow: hidden;
            margin: 12px;
            box-shadow: 0 20px 50px rgba(30, 20, 16, 0.22);
            backdrop-filter: blur(8px);
        }

        .sidebar {
            width: 102px;
            background: rgba(248, 244, 240, 0.92);
            min-height: calc(100vh - 24px);
            border-right: 1px solid rgba(138, 90, 82, 0.08);
            box-shadow: inset -1px 0 0 rgba(255,255,255,0.45);
        }

        .logo-circle {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: linear-gradient(135deg, #f3e7df, #d9c9c0);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--coffee);
            font-size: 26px;
            margin: 24px auto 28px;
            box-shadow: 0 10px 22px rgba(138, 90, 82, 0.18);
            transition: transform 0.25s ease;
        }

        .logo-circle:hover {
            transform: translateY(-2px) scale(1.03);
        }

        .side-icon {
            width: 50px;
            height: 50px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 16px auto;
            color: #625856;
            font-size: 22px;
            text-decoration: none;
            position: relative;
            transition: all 0.25s ease;
        }

        .side-icon:hover {
            background: rgba(138, 90, 82, 0.12);
            color: var(--coffee);
            transform: translateY(-2px);
        }

        .side-icon.active {
            background: linear-gradient(135deg, rgba(138, 90, 82, 0.16), rgba(138, 90, 82, 0.08));
            color: var(--coffee);
            box-shadow: 0 8px 20px rgba(138, 90, 82, 0.12);
        }

        .side-icon.active::after {
            content: "";
            position: absolute;
            right: -13px;
            top: 8px;
            width: 4px;
            height: 34px;
            background: linear-gradient(to bottom, #d78a79, #8a5a52);
            border-radius: 999px;
        }

        .main-content {
            padding: 30px;
            color: #fff;
            width: 100%;
            animation: pageEnterSmooth 0.45s ease;
        }

        .hero-panel {
            background: linear-gradient(135deg, rgba(255,255,255,0.10), rgba(255,255,255,0.05));
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: var(--radius-xl);
            padding: 22px 24px;
            box-shadow: 0 12px 24px rgba(0,0,0,0.12);
            margin-bottom: 24px;
        }

        .hero-title {
            font-size: 30px;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 6px;
        }

        .hero-subtitle {
            color: rgba(255,255,255,0.76);
            margin-bottom: 0;
        }

        .profile-chip {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.10);
            padding: 10px 14px;
            border-radius: 18px;
            backdrop-filter: blur(6px);
            font-weight: 500;
        }

        .content-card {
            border-radius: var(--radius-lg);
            border: 1px solid rgba(138, 90, 82, 0.08);
            background: linear-gradient(180deg, #f8f5f2 0%, #f2ece8 100%);
            color: var(--text-dark);
            box-shadow: var(--shadow-soft);
            overflow: hidden;
        }

        .content-card.card-form {
            position: relative;
        }

        .content-card.card-form::before,
        .content-card.card-table::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 6px;
            background: linear-gradient(to right, #d58d7d, #8a5a52);
        }

        .content-card.card-form,
        .content-card.card-table {
            position: relative;
        }

        .section-title {
            font-weight: 800;
            color: var(--text-dark);
        }

        .form-label {
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 8px;
        }

        .form-control,
        .form-select {
            border-radius: 14px;
            padding: 12px 14px;
            border: 1px solid #ddd3cc;
            background: #fff;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: rgba(138, 90, 82, 0.45);
            box-shadow: 0 0 0 0.25rem rgba(138, 90, 82, 0.10);
        }

        .btn-coffee {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            color: white;
            border-radius: 14px;
            border: none;
            font-weight: 700;
            padding: 11px 18px;
            box-shadow: 0 12px 24px rgba(138, 90, 82, 0.18);
            transition: all 0.25s ease;
        }

        .btn-coffee:hover {
            background: linear-gradient(135deg, var(--coffee-dark), #5b3732);
            color: white;
            transform: translateY(-1px);
        }

        .btn-soft {
            border-radius: 14px;
            font-weight: 700;
            padding: 11px 18px;
        }

        .custom-table {
            margin-bottom: 0;
            overflow: hidden;
            border-radius: 16px;
        }

        .custom-table thead th {
            background: #2f2a28 !important;
            color: #fff !important;
            border: none !important;
            padding: 14px 16px;
            font-size: 14px;
            white-space: nowrap;
        }

        .custom-table tbody td {
            padding: 14px 16px;
            vertical-align: middle;
            border-color: #ece2dc !important;
            color: var(--text-dark);
        }

        .custom-table tbody tr {
            transition: all 0.2s ease;
            background: rgba(255,255,255,0.72);
        }

        .custom-table tbody tr:hover {
            background: #fff;
        }

        .badge-role-admin {
            background: linear-gradient(135deg, #c26654, #8a5a52);
            color: #fff;
            font-weight: 700;
            padding: 7px 12px;
        }

        .badge-role-user {
            background: linear-gradient(135deg, #7b8794, #58616b);
            color: #fff;
            font-weight: 700;
            padding: 7px 12px;
        }

        .action-btn {
            width: 36px;
            height: 36px;
            border: none;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            transition: all 0.2s ease;
            box-shadow: 0 6px 14px rgba(0,0,0,0.08);
        }

        .action-btn:hover {
            transform: translateY(-2px);
        }

        .btn-edit {
            background: #fff3cd;
            color: #946200;
        }

        .btn-delete {
            background: #f8d7da;
            color: #b02a37;
        }

        .top-actions .btn {
            border-radius: 999px;
            padding: 11px 20px;
            font-weight: 700;
            border: none;
        }

        .soft-divider {
            border: none;
            height: 1px;
            background: linear-gradient(to right, transparent, rgba(255,255,255,0.28), transparent);
            margin: 18px 0 24px;
        }

        .empty-text {
            color: var(--text-soft);
            text-align: center;
            padding: 24px 12px;
        }

        @keyframes pageEnterSmooth {
            from {
                opacity: 0;
                transform: translateY(18px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 991.98px) {
            .sidebar {
                width: 84px;
            }

            .main-content {
                padding: 22px 18px 26px;
            }

            .hero-title {
                font-size: 24px;
            }
        }

        @media (max-width: 767.98px) {
            .dashboard-shell {
                margin: 0;
                min-height: 100vh;
                border-radius: 0;
            }

            .sidebar {
                width: 74px;
                min-height: 100vh;
            }

            .logo-circle {
                width: 52px;
                height: 52px;
                font-size: 22px;
            }

            .side-icon {
                width: 44px;
                height: 44px;
                font-size: 20px;
                margin: 12px auto;
            }

            .hero-panel {
                padding: 18px;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-shell d-flex">
    <div class="sidebar d-flex flex-column align-items-center">
        <div class="logo-circle">
            <i class="bi bi-cup-hot-fill"></i>
        </div>

        <a href="<%= ctx %>/admin.jsp" class="side-icon" title="Dashboard">
            <i class="bi bi-speedometer2"></i>
        </a>

        <a href="<%= ctx %>/admin/users" class="side-icon active" title="Quản lý tài khoản">
            <i class="bi bi-people"></i>
        </a>

        <a href="<%= ctx %>/home?category=Kopi" class="side-icon" title="Trang bán hàng">
            <i class="bi bi-cup-straw"></i>
        </a>

        <div class="mt-auto mb-4">
            <a href="<%= ctx %>/logout" class="side-icon" title="Đăng xuất">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>

    <div class="main-content">
        <div class="hero-panel">
            <div class="d-flex justify-content-between align-items-center mb-0 flex-wrap gap-3">
                <div>
                    <div class="small text-uppercase fw-semibold opacity-75 mb-1">Admin / User Management</div>
                    <h2 class="hero-title">Quản lý tài khoản</h2>
                    <p class="hero-subtitle">Thêm, sửa, xóa và phân quyền tài khoản trong hệ thống PolyCoffee.</p>
                </div>

                <div class="d-flex gap-2 flex-wrap top-actions">
                    <a href="<%= ctx %>/admin.jsp" class="btn btn-light">Dashboard</a>
                    <a href="<%= ctx %>/logout" class="btn btn-danger">Đăng xuất</a>
                </div>
            </div>
        </div>

        <hr class="soft-divider">

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="card content-card card-form p-4 h-100">
                    <h4 class="section-title mb-3"><%= isEdit ? "Cập nhật tài khoản" : "Thêm tài khoản" %></h4>

                    <form action="<%= ctx %>/admin/users" method="post">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
                        <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= editUser.getId() %>">
                        <% } %>

                        <div class="mb-3">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" class="form-control"
                                   value="<%= isEdit ? editUser.getFullName() : "" %>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control"
                                   value="<%= isEdit ? editUser.getEmail() : "" %>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Tên đăng nhập</label>
                            <input type="text" name="username" class="form-control"
                                   value="<%= isEdit ? editUser.getUsername() : "" %>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" class="form-control"
                                   placeholder="<%= isEdit ? "Để trống nếu không đổi mật khẩu" : "Nhập mật khẩu" %>">
                        </div>

                        <div class="mb-4">
                            <label class="form-label">Vai trò</label>
                            <select name="role" class="form-select" required>
                                <option value="user" <%= isEdit && "user".equalsIgnoreCase(editUser.getRole()) ? "selected" : "" %>>
                                    User
                                </option>
                                <option value="admin" <%= isEdit && "admin".equalsIgnoreCase(editUser.getRole()) ? "selected" : "" %>>
                                    Admin
                                </option>
                            </select>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-coffee">
                                <%= isEdit ? "Cập nhật" : "Thêm mới" %>
                            </button>
                            <a href="<%= ctx %>/admin/users" class="btn btn-secondary btn-soft">Làm mới</a>
                        </div>
                    </form>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="card content-card card-table p-4">
                    <h4 class="section-title mb-3">Danh sách tài khoản</h4>

                    <div class="table-responsive">
                        <table class="table custom-table align-middle table-hover">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>Username</th>
                                <th>Role</th>
                                <th width="170">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                if (users != null && !users.isEmpty()) {
                                    for (User u : users) {
                            %>
                            <tr>
                                <td><strong>#<%= u.getId() %></strong></td>
                                <td><%= u.getFullName() %></td>
                                <td><%= u.getEmail() %></td>
                                <td><%= u.getUsername() %></td>
                                <td>
                                    <% if ("admin".equalsIgnoreCase(u.getRole())) { %>
                                        <span class="badge badge-role-admin rounded-pill">Admin</span>
                                    <% } else { %>
                                        <span class="badge badge-role-user rounded-pill">User</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="<%= ctx %>/admin/users?action=edit&id=<%= u.getId() %>"
                                       class="action-btn btn-edit"
                                       title="Sửa tài khoản">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>

                                    <form action="<%= ctx %>/admin/users" method="post" class="d-inline"
                                          onsubmit="return confirm('Bạn có chắc muốn xóa tài khoản này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= u.getId() %>">
                                        <button type="submit" class="action-btn btn-delete" title="Xóa tài khoản">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="6" class="empty-text">Chưa có tài khoản nào trong danh sách.</td>
                            </tr>
                            <%
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>