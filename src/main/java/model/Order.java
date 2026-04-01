package model;

import java.util.Date;

public class Order {
    private int id;
    private int userId;
    private String userFullName;
    private double totalAmount;
    private Date createdAt;

    private String status;
    private String paymentMethod;
    private Long payosOrderCode;
    private String payosCheckoutUrl;
    private Date paidAt;

    public Order() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserFullName() {
        return userFullName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Long getPayosOrderCode() {
        return payosOrderCode;
    }

    public void setPayosOrderCode(Long payosOrderCode) {
        this.payosOrderCode = payosOrderCode;
    }

    public String getPayosCheckoutUrl() {
        return payosCheckoutUrl;
    }

    public void setPayosCheckoutUrl(String payosCheckoutUrl) {
        this.payosCheckoutUrl = payosCheckoutUrl;
    }

    public Date getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(Date paidAt) {
        this.paidAt = paidAt;
    }
}