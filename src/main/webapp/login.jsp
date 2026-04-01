<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String registered = request.getParameter("registered");
    String mailSent = request.getParameter("mailSent");
    String resetSuccess = request.getParameter("resetSuccess");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - PolyCoffee</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #5d5a5a, #2f2e2e);
            font-family: Arial, sans-serif;
        }

        .auth-wrapper {
            min-height: 100vh;
        }

        .auth-card {
            border: none;
            border-radius: 28px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
        }

        .auth-left {
            background: linear-gradient(135deg, #8a5a52, #6f4b44);
            color: white;
            padding: 48px;
        }

        .auth-right {
            background: #f8f5f2;
            padding: 48px;
        }

        .brand-circle {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 24px;
        }

        .form-control {
            border-radius: 14px;
            padding: 12px 14px;
        }

        .btn-coffee {
            background: #8a5a52;
            color: white;
            border-radius: 14px;
            padding: 12px;
            border: none;
        }

        .btn-coffee:hover {
            background: #744842;
            color: white;
        }

        .input-group-text {
            border-radius: 14px 0 0 14px;
        }

        .password-toggle {
            cursor: pointer;
        }

        .forgot-link {
            font-size: 14px;
        }

        @media (max-width: 991.98px) {
            .auth-left,
            .auth-right {
                padding: 32px 24px;
            }
        }
    </style>
</head>
<body>
<div class="container auth-wrapper d-flex align-items-center justify-content-center py-5">
    <div class="col-lg-10">
        <div class="card auth-card">
            <div class="row g-0">
                <div class="col-lg-6 auth-left d-flex flex-column justify-content-center">
                    <div class="brand-circle">
                        <i class="bi bi-cup-hot"></i>
                    </div>
                    <h5 class="mb-2">Chào mừng đến với PolyCoffee</h5>
                </div>

                <div class="col-lg-6 auth-right">
                    <h2 class="fw-bold mb-4">Đăng nhập</h2>

                    <% if ("true".equals(registered)) { %>
                        <div class="alert alert-success rounded-4">
                            Bạn đã đăng ký thành công.
                        </div>
                    <% } %>

                    <% if ("true".equals(mailSent)) { %>
                        <div class="alert alert-info rounded-4">
                            Hệ thống đã gửi email chào mừng đến hộp thư của bạn.
                        </div>
                    <% } %>

                    <% if ("true".equals(resetSuccess)) { %>
                        <div class="alert alert-success rounded-4">
                            Đổi mật khẩu thành công. Vui lòng đăng nhập lại.
                        </div>
                    <% } %>

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger rounded-4"><%= request.getAttribute("error") %></div>
                    <% } %>

                    <form action="<%= ctx %>/login" method="post">
                        <div class="mb-3">
                            <label class="form-label">Tên đăng nhập</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" name="username" class="form-control" placeholder="Nhập username" required>
                            </div>
                        </div>

                        <div class="mb-2">
                            <label class="form-label">Mật khẩu</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" id="loginPassword" class="form-control" placeholder="Nhập mật khẩu" required>
                                <span class="input-group-text password-toggle" onclick="togglePassword('loginPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </span>
                            </div>
                        </div>

                        <div class="text-end mb-4">
                            <a href="<%= ctx %>/forgot-password" class="text-decoration-none forgot-link">
                                Quên mật khẩu?
                            </a>
                        </div>

                        <button type="submit" class="btn btn-coffee w-100">Đăng nhập</button>
                    </form>

                    <p class="mt-4 mb-0 text-center">
                        Chưa có tài khoản?
                        <a href="<%= ctx %>/register" class="text-decoration-none fw-semibold">Đăng ký ngay</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function togglePassword(id, el) {
        const input = document.getElementById(id);
        const icon = el.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>