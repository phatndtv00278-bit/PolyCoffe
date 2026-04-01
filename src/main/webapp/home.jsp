<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="model.CartItem" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();

    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    List<Product> products = (List<Product>) request.getAttribute("products");
    Product editProduct = (Product) request.getAttribute("editProduct");
    boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
    boolean isEdit = editProduct != null;
    String currentCategory = (String) request.getAttribute("currentCategory");
    String keyword = (String) request.getAttribute("keyword");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");

    if (keyword == null) keyword = "";
    if (currentCategory == null || currentCategory.isBlank()) currentCategory = "Kopi";
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;

    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute("cart", cart);
    }

    int cartTotalQty = 0;
    double cartTotalAmount = 0;
    for (CartItem item : cart) {
        cartTotalQty += item.getQuantity();
        cartTotalAmount += item.getPrice() * item.getQuantity();
    }

    String successMessage = (String) session.getAttribute("successMessage");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ - PolyCoffee</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        :root {
            --coffee: #8a5a52;
            --coffee-dark: #6d433d;
            --coffee-soft: #b8867d;
            --cream: #f7f2ee;
            --text-dark: #2f2a28;
            --text-soft: #7a6d68;
            --success-bg: #e9f8ef;
            --shadow-soft: 0 10px 30px rgba(37, 24, 19, 0.10);
            --shadow-hover: 0 18px 38px rgba(37, 24, 19, 0.16);
            --radius-xl: 28px;
            --radius-lg: 22px;
        }

        * { box-sizing: border-box; }

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
        }

        .sidebar {
            width: 102px;
            background: rgba(248, 244, 240, 0.92);
            min-height: calc(100vh - 24px);
            border-right: 1px solid rgba(138, 90, 82, 0.08);
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
            padding: 30px 30px 34px;
            color: #fff;
        }

        .hero-panel {
            background: linear-gradient(135deg, rgba(255,255,255,0.10), rgba(255,255,255,0.05));
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: var(--radius-xl);
            padding: 22px 24px;
            box-shadow: 0 12px 24px rgba(0,0,0,0.12);
            margin-bottom: 22px;
        }

        .hero-title {
            font-size: 30px;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 6px;
        }

        .search-form-wrap {
            position: relative;
            min-width: 360px;
        }

        .search-wrap {
            position: relative;
            width: 100%;
        }

        .search-wrap i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #ead9d6;
            font-size: 15px;
            pointer-events: none;
        }

        .search-box {
            background: rgba(138, 90, 82, 0.85);
            border: 1px solid rgba(255,255,255,0.08);
            color: white;
            border-radius: 18px;
            padding: 12px 18px 12px 40px;
            min-height: 48px;
        }

        .search-box:focus {
            background: rgba(138, 90, 82, 0.95);
            color: #fff;
            border-color: rgba(255,255,255,0.25);
            box-shadow: 0 0 0 0.25rem rgba(255,255,255,0.08);
        }

        .search-box::placeholder { color: #ead9d6; }

        .suggest-box {
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            right: 0;
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 18px 30px rgba(0,0,0,0.14);
            overflow: hidden;
            z-index: 1000;
            display: none;
        }

        .suggest-item {
            padding: 12px 14px;
            color: #2f2a28;
            cursor: pointer;
            border-bottom: 1px solid #f0e6df;
            transition: background 0.2s ease;
        }

        .suggest-item:last-child { border-bottom: none; }

        .suggest-item:hover,
        .suggest-item.active {
            background: #f8f1ec;
        }

        .suggest-type {
            font-size: 12px;
            color: #8a5a52;
            font-weight: 700;
            margin-right: 8px;
        }

        .profile-chip {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.10);
            padding: 8px 12px;
            border-radius: 18px;
        }

        .top-avatar {
            width: 54px;
            height: 54px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid rgba(255,255,255,0.22);
            box-shadow: 0 8px 20px rgba(0,0,0,0.16);
        }

        .admin-panel-btn {
            border-radius: 999px;
            padding: 11px 20px;
            font-weight: 700;
            border: none;
        }

        .soft-divider {
            border: none;
            height: 1px;
            background: linear-gradient(to right, transparent, rgba(255,255,255,0.28), transparent);
            margin: 18px 0 22px;
        }

        .glass-alert {
            border-radius: 18px;
            border: none;
            background: var(--success-bg);
            box-shadow: var(--shadow-soft);
        }

        .admin-form-card,
        .menu-card {
            border-radius: var(--radius-lg);
            background: linear-gradient(180deg, #f8f5f2 0%, #f2ece8 100%);
            border: 1px solid rgba(138, 90, 82, 0.08);
            overflow: hidden;
            color: var(--text-dark);
            box-shadow: var(--shadow-soft);
        }

        .admin-form-card {
            position: relative;
        }

        .admin-form-card::before {
            content: "";
            position: absolute;
            inset: 0 0 auto 0;
            height: 6px;
            background: linear-gradient(to right, #d58d7d, #8a5a52);
        }

        .section-title {
            font-weight: 800;
            letter-spacing: 0.2px;
        }

        .menu-img {
            width: 108px;
            height: 108px;
            object-fit: cover;
            border-radius: 20px;
            background: #ddd;
            box-shadow: 0 8px 18px rgba(0,0,0,0.08);
            flex-shrink: 0;
        }

        .menu-card {
            transition: all 0.28s ease;
        }

        .menu-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-hover);
        }

        .coffee-btn {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            color: white;
            border: none;
            border-radius: 14px;
            font-weight: 700;
            min-height: 44px;
            box-shadow: 0 12px 24px rgba(138, 90, 82, 0.18);
            transition: all 0.25s ease;
        }

        .coffee-btn:hover {
            background: linear-gradient(135deg, var(--coffee-dark), #5b3732);
            color: white;
        }

        .size-group {
            display: flex;
            gap: 10px;
            margin-bottom: 12px;
        }

        .size-btn {
            min-width: 46px;
            height: 42px;
            border-radius: 999px;
            border: none;
            background: #ece8e5;
            color: #2f2a28;
            font-size: 14px;
            font-weight: 700;
            transition: all 0.2s ease;
        }

        .size-btn:hover {
            transform: translateY(-1px);
        }

        .size-btn.active {
            background: linear-gradient(135deg, var(--coffee), var(--coffee-dark));
            color: white;
            box-shadow: 0 8px 16px rgba(138, 90, 82, 0.18);
        }

        .admin-form-card .form-control,
        .admin-form-card .form-select,
        .admin-form-card textarea {
            border-radius: 14px;
            padding: 11px 13px;
            border: 1px solid #ddd3cc;
            background: #fff;
        }

        .action-btn {
            width: 36px;
            height: 36px;
            border: none;
            background: #fff;
            border-radius: 12px;
            font-size: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 6px 14px rgba(0,0,0,0.08);
            text-decoration: none;
        }

        .status-off {
            opacity: 0.55;
            filter: grayscale(0.08);
        }

        .current-preview {
            width: 112px;
            height: 112px;
            object-fit: cover;
            border-radius: 16px;
            border: 1px solid #ddd;
            background: #eee;
        }

        .category-tabs {
            gap: 12px;
            margin-bottom: 26px;
        }

        .category-btn {
            border-radius: 999px !important;
            padding: 11px 22px !important;
            font-weight: 700 !important;
            min-width: 120px;
        }

        .product-price {
            color: var(--coffee-dark);
            font-size: 18px;
            font-weight: 800;
        }

        .menu-desc {
            min-height: 38px;
            color: var(--text-soft);
        }

        .cart-panel {
            position: sticky;
            top: 24px;
        }

        .cart-img {
            width: 72px;
            height: 72px;
            object-fit: cover;
            border-radius: 16px;
            background: #ddd;
        }

        .cart-item-box {
            border: 1px solid #eee4de;
            border-radius: 18px;
            padding: 14px;
            background: linear-gradient(180deg, #fff 0%, #faf7f4 100%);
        }

        .qty-btn {
            width: 34px;
            height: 34px;
            border-radius: 10px;
            font-weight: 700;
        }

        .cart-summary {
            background: #fff;
            border-radius: 18px;
            padding: 16px;
            border: 1px dashed #ddcec4;
        }

        .empty-cart {
            text-align: center;
            padding: 28px 16px;
            background: linear-gradient(180deg, #fff 0%, #f8f4f1 100%);
            border-radius: 20px;
            border: 1px dashed #dfd1c7;
        }

        .empty-cart i {
            font-size: 38px;
            color: var(--coffee-soft);
            margin-bottom: 10px;
            display: inline-block;
        }

        .text-gradient {
            background: linear-gradient(135deg, #fff, #f3d7ca);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .pagination .page-link {
            color: #8a5a52;
            border-radius: 10px;
            margin: 0 4px;
            border: none;
            min-width: 42px;
            text-align: center;
            box-shadow: 0 6px 14px rgba(0,0,0,0.07);
        }

        .pagination .page-item.active .page-link {
            background: #8a5a52;
            border-color: #8a5a52;
            color: white;
        }

        .modal-content {
            background: #f8f5f2;
            border-radius: 20px;
        }

        .qr-note {
            background: #fff;
            border: 1px dashed #d9c9c0;
            border-radius: 14px;
            padding: 10px 12px;
        }

        .page-transition-overlay {
            position: fixed;
            inset: 0;
            background: rgba(33, 28, 28, 0.32);
            backdrop-filter: blur(2px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }

        .page-transition-overlay.show {
            display: flex;
        }

        .page-loader-box {
            background: rgba(255,255,255,0.95);
            color: #4d342e;
            padding: 18px 22px;
            border-radius: 18px;
            box-shadow: 0 14px 30px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 700;
        }

        .page-loader-spinner {
            width: 22px;
            height: 22px;
            border: 3px solid #d7c2b9;
            border-top-color: #8a5a52;
            border-radius: 50%;
            animation: spin 0.75s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        @media (max-width: 991.98px) {
            .cart-panel { position: static; }
            .sidebar { width: 84px; }
            .main-content { padding: 22px 18px 26px; }
            .hero-title { font-size: 24px; }
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

            .hero-panel { padding: 18px; }
            .menu-img { width: 92px; height: 92px; }
            .category-btn { min-width: unset; width: 100%; }
            .search-form-wrap { min-width: 100%; }
        }
    </style>
</head>
<body>
<div class="dashboard-shell d-flex">
    <div class="sidebar d-flex flex-column align-items-center">
        <div class="logo-circle">
            <i class="bi bi-cup-hot-fill"></i>
        </div>

        <a href="<%= ctx %>/home?category=<%= currentCategory %>&keyword=<%= keyword %>"
           class="side-icon active" title="Trang chủ">
            <i class="bi bi-house-door-fill"></i>
        </a>

        <a href="<%= ctx %>/purchase-history" class="side-icon" title="Lịch sử mua hàng">
            <i class="bi bi-clock-history"></i>
        </a>

        <% if (isAdmin) { %>
            <a href="<%= ctx %>/admin/dashboard" class="side-icon" title="Thống kê doanh thu">
                <i class="bi bi-bar-chart-line-fill"></i>
            </a>

            <a href="<%= ctx %>/admin/orders" class="side-icon" title="Danh sách hóa đơn">
                <i class="bi bi-wallet2"></i>
            </a>
        <% } %>

        <div class="mt-auto mb-4">
            <a href="<%= ctx %>/logout" class="side-icon" title="Đăng xuất">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>

    <div class="flex-grow-1 main-content">
        <div class="hero-panel">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <div class="small text-uppercase fw-semibold opacity-75 mb-1">PolyCoffee Dashboard</div>
                    <h2 class="hero-title text-gradient">Chào mừng bạn đến với PolyCoffee</h2>
                </div>

                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <div class="search-form-wrap">
                        <form id="smartSearchForm" action="<%= ctx %>/home" method="get" class="d-flex align-items-center gap-2 flex-wrap">
                            <div class="search-wrap">
                                <i class="bi bi-search"></i>
                                <input type="text" id="smartSearchInput" name="keyword" class="form-control search-box"
                                       placeholder="Tìm menu hoặc gõ: tr, tra sua, cafe..." value="<%= keyword %>" autocomplete="off">
                                <div id="suggestBox" class="suggest-box"></div>
                            </div>
                        </form>
                    </div>

                    <div class="d-flex align-items-center gap-2 profile-chip">
                        <img src="https://i.pravatar.cc/100?img=12" class="top-avatar" alt="avatar">
                        <div>
                            <div class="small opacity-75"><%= user.getRole() %></div>
                            <div class="fw-semibold"><%= user.getFullName() %></div>
                        </div>
                    </div>

                    <% if (isAdmin) { %>
                        <a href="<%= ctx %>/admin-user.jsp" class="btn btn-light admin-panel-btn">Admin panel</a>
                    <% } %>
                </div>
            </div>
        </div>

        <hr class="soft-divider">

        <% if (successMessage != null) { %>
            <div class="alert glass-alert alert-success mb-4"><%= successMessage %></div>
        <%
                session.removeAttribute("successMessage");
           }
        %>

        <% if (isAdmin) { %>
        <div class="card admin-form-card p-4 mb-4">
            <h4 class="section-title mb-3"><%= isEdit ? "Cập nhật món" : "Thêm món mới" %></h4>

            <form action="<%= ctx %>/admin/product" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= editProduct.getId() %>">
                <% } %>

                <div class="row g-3">
                    <div class="col-md-4">
                        <input type="text" name="name" class="form-control" placeholder="Tên món"
                               value="<%= isEdit ? editProduct.getName() : "" %>" required>
                    </div>

                    <div class="col-md-4">
                        <input type="number" step="0.01" name="price" class="form-control" placeholder="Giá"
                               value="<%= isEdit ? editProduct.getPrice() : "" %>" required>
                    </div>

                    <div class="col-md-4">
                        <select name="category" class="form-select" required>
                            <option value="Kopi"
                                <%= isEdit && "Kopi".equalsIgnoreCase(editProduct.getCategory()) ? "selected" : (!isEdit ? "selected" : "") %>>
                                Cafe
                            </option>
                            <option value="TraSua"
                                <%= isEdit && "TraSua".equalsIgnoreCase(editProduct.getCategory()) ? "selected" : "" %>>
                                Trà sữa
                            </option>
                            <option value="TraTraiCay"
                                <%= isEdit && "TraTraiCay".equalsIgnoreCase(editProduct.getCategory()) ? "selected" : "" %>>
                                Trà trái cây
                            </option>
                        </select>
                    </div>

                    <div class="col-md-8">
                        <label class="form-label fw-semibold">Chọn ảnh món</label>
                        <input type="file" name="imageFile" class="form-control" accept="image/*">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Trạng thái</label>
                        <select name="status" class="form-select">
                            <option value="1" <%= isEdit && editProduct.isStatus() ? "selected" : (!isEdit ? "selected" : "") %>>Hiển thị</option>
                            <option value="0" <%= isEdit && !editProduct.isStatus() ? "selected" : "" %>>Ẩn</option>
                        </select>
                    </div>

                    <% if (isEdit && editProduct.getImageUrl() != null && !editProduct.getImageUrl().isBlank()) { %>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Ảnh hiện tại</label>
                        <div>
                            <img src="<%= ctx + "/" + editProduct.getImageUrl() %>" alt="Ảnh món" class="current-preview">
                        </div>
                    </div>
                    <% } %>

                    <div class="col-12">
                        <textarea name="description" class="form-control" rows="3" placeholder="Mô tả"><%= isEdit ? editProduct.getDescription() : "" %></textarea>
                    </div>

                    <div class="col-12 d-flex gap-2 flex-wrap">
                        <button type="submit" class="btn coffee-btn px-4">
                            <%= isEdit ? "Cập nhật món" : "Thêm món" %>
                        </button>
                        <a href="<%= ctx %>/home?category=<%= currentCategory %>&keyword=<%= keyword %>&page=<%= currentPage %>" class="btn btn-secondary px-4 rounded-4">
                            Làm mới
                        </a>
                    </div>
                </div>
            </form>
        </div>
        <% } %>

        <div class="d-flex flex-wrap category-tabs">
            <a href="<%= ctx %>/home?category=Kopi" class="btn category-btn <%= "Kopi".equals(currentCategory) ? "coffee-btn" : "btn-light" %>">
                <i class="bi bi-cup-hot me-1"></i> Cafe
            </a>

            <a href="<%= ctx %>/home?category=TraSua" class="btn category-btn <%= "TraSua".equals(currentCategory) ? "coffee-btn" : "btn-light" %>">
                <i class="bi bi-droplet-half me-1"></i> Trà sữa
            </a>

            <a href="<%= ctx %>/home?category=TraTraiCay" class="btn category-btn <%= "TraTraiCay".equals(currentCategory) ? "coffee-btn" : "btn-light" %>">
                <i class="bi bi-emoji-smile me-1"></i> Trà trái cây
            </a>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                <h2 class="fw-bold mb-4">
                    <%= "Kopi".equals(currentCategory) ? "Menu Cafe" :
                        "TraSua".equals(currentCategory) ? "Menu Trà sữa" :
                        "TraTraiCay".equals(currentCategory) ? "Menu Trà trái cây" :
                        "Menu" %>
                </h2>

                <div class="row g-4">
                    <%
                        if (products != null && !products.isEmpty()) {
                            for (Product p : products) {
                    %>
                    <div class="col-md-6">
                        <div class="card menu-card p-3 <%= !p.isStatus() ? "status-off" : "" %>">
                            <div class="d-flex gap-3 align-items-start">
                                <img class="menu-img"
                                     src="<%= (p.getImageUrl() != null && !p.getImageUrl().isBlank())
                                            ? (ctx + "/" + p.getImageUrl())
                                            : "https://via.placeholder.com/100" %>"
                                     alt="">

                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-start gap-2 mb-1">
                                        <h5 class="fw-bold mb-0"><%= p.getName() %></h5>

                                        <% if (isAdmin) { %>
                                        <div class="d-flex align-items-start gap-2 flex-shrink-0">
                                            <a href="<%= ctx %>/home?category=<%= currentCategory %>&keyword=<%= keyword %>&page=<%= currentPage %>&editId=<%= p.getId() %>"
                                               class="action-btn text-warning"
                                               title="Sửa món">
                                                <i class="bi bi-pencil-square"></i>
                                            </a>

                                            <form action="<%= ctx %>/admin/product" method="post" class="d-inline"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa món này?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                                <input type="hidden" name="keyword" value="<%= keyword %>">
                                                <input type="hidden" name="page" value="<%= currentPage %>">
                                                <button type="submit" class="action-btn text-danger" title="Xóa món">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </form>

                                            <form action="<%= ctx %>/admin/product" method="post" class="d-inline"
                                                  onsubmit="return confirm('Bạn có chắc muốn ẩn món này?');">
                                                <input type="hidden" name="action" value="hide">
                                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                                <input type="hidden" name="keyword" value="<%= keyword %>">
                                                <input type="hidden" name="page" value="<%= currentPage %>">
                                                <button type="submit" class="action-btn text-secondary" title="Ẩn món">
                                                    <i class="bi bi-eye-slash"></i>
                                                </button>
                                            </form>

                                            <form action="<%= ctx %>/admin/product" method="post" class="d-inline"
                                                  onsubmit="return confirm('Bạn có muốn hiện lại món này?');">
                                                <input type="hidden" name="action" value="show">
                                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                                <input type="hidden" name="keyword" value="<%= keyword %>">
                                                <input type="hidden" name="page" value="<%= currentPage %>">
                                                <button type="submit" class="action-btn text-success" title="Hiện lại món">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                            </form>
                                        </div>
                                        <% } %>
                                    </div>

                                    <p class="menu-desc small mb-2"><%= p.getDescription() %></p>

                                    <div class="d-flex justify-content-between align-items-center small mb-2 flex-wrap gap-2">
                                        <span class="text-secondary">Danh mục <b><%= p.getCategory() %></b></span>
                                        <span class="product-price" id="showPrice-<%= p.getId() %>">
                                            <%= String.format("%,.0f", p.getPrice()) %>đ
                                        </span>
                                    </div>

                                    <form action="<%= ctx %>/cart" method="post">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="productId" value="<%= p.getId() %>">
                                        <input type="hidden" name="category" value="<%= currentCategory %>">
                                        <input type="hidden" name="size" id="size-<%= p.getId() %>" value="S">
                                        <input type="hidden" name="price" id="price-<%= p.getId() %>" value="<%= (long)p.getPrice() %>">

                                        <div class="size-group" data-id="<%= p.getId() %>">
                                            <button type="button" class="size-btn active" data-size="S">S</button>
                                            <button type="button" class="size-btn" data-size="M">M</button>
                                            <button type="button" class="size-btn" data-size="L">L</button>
                                        </div>

                                        <button type="submit" class="btn coffee-btn w-100">
                                            <i class="bi bi-bag-plus me-1"></i> Thêm vào đơn
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="col-12">
                        <div class="card menu-card p-4 text-center">
                            <h5 class="fw-bold mb-2">Không tìm thấy sản phẩm phù hợp</h5>
                            <div class="text-secondary">Bạn thử nhập tên món khác hoặc chọn một mục gợi ý như Cafe, Trà sữa, Trà trái cây.</div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>

                <% if (totalPages > 1) { %>
                    <nav class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                                <a class="page-link" href="<%= ctx %>/home?category=<%= currentCategory %>&keyword=<%= keyword %>&page=<%= currentPage - 1 %>">Trước</a>
                            </li>

                            <% for (int i = 1; i <= totalPages; i++) { %>
                                <li class="page-item <%= i == currentPage ? "active" : "" %>">
                                    <a class="page-link" href="<%= ctx %>/home?category=<%= currentCategory %>&keyword=<%= keyword %>&page=<%= i %>"><%= i %></a>
                                </li>
                            <% } %>

                            <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                                <a class="page-link" href="<%= ctx %>/home?category=<%= currentCategory %>&keyword=<%= keyword %>&page=<%= currentPage + 1 %>">Sau</a>
                            </li>
                        </ul>
                    </nav>
                <% } %>
            </div>

            <div class="col-lg-4">
                <div class="card menu-card p-4 cart-panel">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 class="fw-bold mb-0">Giỏ hàng</h4>
                        <span class="badge rounded-pill bg-dark px-3 py-2"><%= cartTotalQty %> món</span>
                    </div>

                    <% if (cart.isEmpty()) { %>
                        <div class="empty-cart">
                            <i class="bi bi-cart3"></i>
                            <div class="fw-bold mb-1">Chưa có món nào trong đơn</div>
                            <div class="text-secondary small">Hãy chọn món ở danh sách bên trái để thêm vào giỏ hàng.</div>
                        </div>
                    <% } else { %>

                        <div class="d-flex flex-column gap-3">
                            <% for (CartItem item : cart) { %>
                                <div class="cart-item-box">
                                    <div class="d-flex gap-3">
                                        <img
                                            src="<%= (item.getProduct().getImageUrl() != null && !item.getProduct().getImageUrl().isBlank())
                                                    ? (ctx + "/" + item.getProduct().getImageUrl())
                                                    : "https://via.placeholder.com/80" %>"
                                            alt=""
                                            class="cart-img">

                                        <div class="flex-grow-1">
                                            <div class="fw-bold"><%= item.getProduct().getName() %></div>
                                            <div class="small text-secondary">
                                                <%= item.getProduct().getCategory() %> - Size <strong><%= item.getSize() %></strong>
                                            </div>
                                            <div class="fw-semibold mt-1 product-price">
                                                <%= String.format("%,.0f", item.getPrice()) %>đ
                                            </div>
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-between align-items-center mt-3 gap-3 flex-wrap">
                                        <div class="d-flex align-items-center gap-2">
                                            <form action="<%= ctx %>/cart" method="post" class="d-inline">
                                                <input type="hidden" name="action" value="decrease">
                                                <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
                                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                                <input type="hidden" name="size" value="<%= item.getSize() %>">
                                                <button type="submit" class="btn btn-outline-secondary btn-sm qty-btn">-</button>
                                            </form>

                                            <span class="fw-bold px-2"><%= item.getQuantity() %></span>

                                            <form action="<%= ctx %>/cart" method="post" class="d-inline">
                                                <input type="hidden" name="action" value="increase">
                                                <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
                                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                                <input type="hidden" name="size" value="<%= item.getSize() %>">
                                                <button type="submit" class="btn btn-outline-secondary btn-sm qty-btn">+</button>
                                            </form>
                                        </div>

                                        <div class="text-end">
                                            <div class="fw-bold mb-1">
                                                <%= String.format("%,.0f", item.getPrice() * item.getQuantity()) %>đ
                                            </div>

                                            <form action="<%= ctx %>/cart" method="post">
                                                <input type="hidden" name="action" value="remove">
                                                <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
                                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                                <input type="hidden" name="size" value="<%= item.getSize() %>">
                                                <button type="submit" class="btn btn-sm btn-danger rounded-3">Xóa</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <hr>

                        <div class="cart-summary">
                            <div class="d-flex justify-content-between mb-2">
                                <span>Tổng số lượng</span>
                                <strong><%= cartTotalQty %></strong>
                            </div>

                            <div class="d-flex justify-content-between mb-3">
                                <span>Tổng tiền</span>
                                <strong class="product-price"><%= String.format("%,.0f", cartTotalAmount) %>đ</strong>
                            </div>

                            <form action="<%= ctx %>/cart" method="post">
                                <input type="hidden" name="action" value="clear">
                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                <button type="submit" class="btn btn-outline-danger w-100 rounded-4">
                                    Xóa toàn bộ giỏ hàng
                                </button>
                            </form>

                            <form action="<%= ctx %>/checkout" method="post" class="mt-2">
                                <button type="submit" class="btn coffee-btn w-100">
                                    <i class="bi bi-cash-coin me-1"></i> Thanh toán tiền mặt
                                </button>
                            </form>

                            <button type="button" class="btn btn-dark w-100 mt-2 rounded-4" data-bs-toggle="modal" data-bs-target="#qrModal">
                                <i class="bi bi-qr-code me-1"></i> Thanh toán QR
                            </button>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="qrModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-dark">
                    <i class="bi bi-qr-code me-2"></i>Thanh toán bằng PayOS
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body text-center">
                <% if (cartTotalQty > 0) { %>
                    <p class="text-dark mb-2">Nhấn nút bên dưới để chuyển sang trang thanh toán PayOS</p>

                    <div class="fw-bold fs-4 mb-3 text-danger">
                        <%= String.format("%,.0f", cartTotalAmount) %>đ
                    </div>

                    <div class="qr-note mt-3 text-dark small">
                        Sau khi thanh toán xong, hệ thống sẽ tự cập nhật trạng thái hóa đơn.
                    </div>

                    <form action="<%= ctx %>/checkout/qr/confirm" method="post" class="mt-4">
                        <button type="submit" class="btn coffee-btn w-100">
                            <i class="bi bi-box-arrow-up-right me-1"></i> Thanh toán với PayOS
                        </button>
                    </form>
                <% } else { %>
                    <div class="text-dark">Giỏ hàng đang trống.</div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<div id="pageTransitionOverlay" class="page-transition-overlay">
    <div class="page-loader-box">
        <div class="page-loader-spinner"></div>
        <span>Đang chuyển menu...</span>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    (function () {
        const overlay = document.getElementById("pageTransitionOverlay");

        function smoothNavigate(url) {
            if (overlay) overlay.classList.add("show");
            setTimeout(function () {
                window.location.href = url;
            }, 180);
        }

        document.querySelectorAll('a[href]').forEach(function (link) {
            const href = link.getAttribute('href');
            if (!href) return;

            const isInternal =
                href.includes('/home?category=') ||
                href.includes('/admin/dashboard') ||
                href.includes('/admin/orders') ||
                href.includes('/admin.jsp') ||
                href.includes('/admin-user.jsp');

            if (isInternal) {
                link.addEventListener('click', function (e) {
                    if (e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
                    e.preventDefault();
                    smoothNavigate(this.href);
                });
            }
        });

        window.addEventListener('pageshow', function () {
            if (overlay) overlay.classList.remove("show");
        });
    })();

    (function () {
        const input = document.getElementById("smartSearchInput");
        const box = document.getElementById("suggestBox");
        const form = document.getElementById("smartSearchForm");
        if (!input || !box || !form) return;

        const suggestions = [
            { label: "Cafe", type: "Danh mục", url: "<%= ctx %>/home?category=Kopi" },
            { label: "Trà sữa", type: "Danh mục", url: "<%= ctx %>/home?category=TraSua" },
            { label: "Trà trái cây", type: "Danh mục", url: "<%= ctx %>/home?category=TraTraiCay" }
        ];

        let activeIndex = -1;
        let filtered = [];

        function normalize(text) {
            return text
                .toLowerCase()
                .normalize("NFD")
                .replace(/[\u0300-\u036f]/g, "")
                .replace(/đ/g, "d")
                .trim();
        }

        function renderSuggestions(items) {
            if (!items.length) {
                box.style.display = "none";
                box.innerHTML = "";
                return;
            }

            let html = "";
            for (let i = 0; i < items.length; i++) {
                const item = items[i];
                const activeClass = (i === activeIndex) ? " active" : "";
                html += '<div class="suggest-item' + activeClass + '" data-url="' + item.url + '">';
                html += '<span class="suggest-type">' + item.type + '</span>' + item.label;
                html += '</div>';
            }

            box.innerHTML = html;
            box.style.display = "block";

            box.querySelectorAll(".suggest-item").forEach(function (el) {
                el.addEventListener("click", function () {
                    window.location.href = this.dataset.url;
                });
            });
        }

        function updateSuggest() {
            const value = normalize(input.value);
            if (!value) {
                box.style.display = "none";
                box.innerHTML = "";
                activeIndex = -1;
                return;
            }

            filtered = suggestions.filter(function (item) {
                return normalize(item.label).includes(value);
            });
            activeIndex = -1;
            renderSuggestions(filtered);
        }

        input.addEventListener("input", updateSuggest);

        input.addEventListener("keydown", function (e) {
            if (!filtered.length) return;

            if (e.key === "ArrowDown") {
                e.preventDefault();
                activeIndex = (activeIndex + 1) % filtered.length;
                renderSuggestions(filtered);
            } else if (e.key === "ArrowUp") {
                e.preventDefault();
                activeIndex = (activeIndex - 1 + filtered.length) % filtered.length;
                renderSuggestions(filtered);
            } else if (e.key === "Enter" && activeIndex >= 0) {
                e.preventDefault();
                window.location.href = filtered[activeIndex].url;
            }
        });

        document.addEventListener("click", function (e) {
            if (!box.contains(e.target) && e.target !== input) {
                box.style.display = "none";
            }
        });

        form.addEventListener("submit", function (e) {
            const value = normalize(input.value);

            if (value === "c" || value === "ca" || value === "caf" || value === "cafe" || value === "caphe" || value.includes("ca phe")) {
                e.preventDefault();
                window.location.href = "<%= ctx %>/home?category=Kopi";
                return;
            }

            if (value === "t" || value === "tr" || value === "tra" || value.includes("tra sua") || value.includes("trasua")) {
                e.preventDefault();
                window.location.href = "<%= ctx %>/home?category=TraSua";
                return;
            }

            if (value.includes("tra trai") || value.includes("trai cay") || value.includes("tra trai cay")) {
                e.preventDefault();
                window.location.href = "<%= ctx %>/home?category=TraTraiCay";
            }
        });
    })();

    document.querySelectorAll(".size-group").forEach(function (group) {
        const id = group.dataset.id;
        const priceInput = document.getElementById("price-" + id);
        const sizeInput = document.getElementById("size-" + id);
        const showPrice = document.getElementById("showPrice-" + id);

        if (!priceInput || !sizeInput || !showPrice) return;

        const basePrice = parseInt(priceInput.value);

        group.querySelectorAll(".size-btn").forEach(function (btn) {
            btn.addEventListener("click", function () {
                group.querySelectorAll(".size-btn").forEach(function (b) {
                    b.classList.remove("active");
                });

                btn.classList.add("active");

                const size = btn.dataset.size;
                let newPrice = basePrice;

                if (size === "M") newPrice += 10000;
                if (size === "L") newPrice += 20000;

                sizeInput.value = size;
                priceInput.value = newPrice;
                showPrice.innerText = newPrice.toLocaleString("vi-VN") + "đ";
            });
        });
    });
</script>
</body>
</html>