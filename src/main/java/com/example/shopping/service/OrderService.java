package com.example.shopping.service;

import com.example.shopping.entity.*;
import com.example.shopping.mapper.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class OrderService {

    private final OrderMapper orderMapper;
    private final RefundMapper refundMapper;
    private final ComplaintMapper complaintMapper;

    public OrderService(OrderMapper orderMapper, RefundMapper refundMapper, ComplaintMapper complaintMapper) {
        this.orderMapper = orderMapper;
        this.refundMapper = refundMapper;
        this.complaintMapper = complaintMapper;
    }

    public Order findById(Long id) {
        Order order = orderMapper.findById(id);
        if (order != null) {
            checkAndUpdateOrderStatus(order);
            setOrderFlags(order);
        }
        return order;
    }

    public List<Order> findByUserId(Long userId) {
        List<Order> orders = orderMapper.findByUserId(userId);
        for (Order order : orders) {
            checkAndUpdateOrderStatus(order);
            setOrderFlags(order);
        }
        return orders;
    }

    public List<Order> findByMerchantId(Long merchantId) {
        List<Order> orders = orderMapper.findByMerchantId(merchantId);
        for (Order order : orders) {
            checkAndUpdateOrderStatus(order);
        }
        return orders;
    }

    public List<Order> findAll() {
        List<Order> orders = orderMapper.findAll();
        for (Order order : orders) {
            checkAndUpdateOrderStatus(order);
        }
        return orders;
    }

    private void checkAndUpdateOrderStatus(Order order) {
        try {
            LocalDateTime now = LocalDateTime.now();

            if ("pending".equals(order.getStatus()) && order.getCreatedAt() != null) {
                long hours = ChronoUnit.HOURS.between(order.getCreatedAt(), now);
                if (hours >= 24) {
                    order.setStatus("cancelled");
                    orderMapper.updateStatus(order);
                }
            }

            if ("delivered".equals(order.getStatus()) && order.getDeliveredAt() != null) {
                long days = ChronoUnit.DAYS.between(order.getDeliveredAt(), now);
                if (days >= 7) {
                    order.setStatus("completed");
                    order.setCompletedAt(now);
                    orderMapper.update(order);
                }
            }
        } catch (Exception e) {
            // ignore update errors
        }
    }

    private void setOrderFlags(Order order) {
        order.setCanComplaint(false);
        order.setCanRefund(false);
        order.setHasComplaint(false);
        order.setHasRefund(false);
        order.setComplaintStatus(null);
        order.setComplaintResult(null);
        order.setRefundStatus(null);
        order.setRefundResult(null);
        order.setRefundProcessedAt(null);
        order.setCanEscalateRefund(false);

        try {
            Complaint complaint = complaintMapper.findByOrderId(order.getId());
            order.setHasComplaint(complaint != null);
            if (complaint != null) {
                order.setComplaintStatus(complaint.getStatus());
                order.setComplaintResult(complaint.getResult());
            }

            Refund refund = refundMapper.findByOrderId(order.getId());
            order.setHasRefund(refund != null);
            if (refund != null) {
                order.setRefundStatus(refund.getStatus());
                order.setRefundResult(refund.getResult());
                order.setRefundProcessedAt(refund.getProcessedAt());
                order.setCanEscalateRefund("rejected".equals(refund.getStatus()));
            }

            String status = order.getStatus();
            if ("completed".equals(status) || "reviewed".equals(status)) {
                order.setCanComplaint(complaint == null);
                if (refund == null && order.getCompletedAt() != null) {
                    long days = ChronoUnit.DAYS.between(order.getCompletedAt(), LocalDateTime.now());
                    order.setCanRefund(days <= 7);
                }
            }
        } catch (Exception e) {
            // ignore flag errors
        }
    }

    @Transactional
    public void acceptOrder(Long orderId, Long merchantId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getMerchantId().equals(merchantId) && "pending".equals(order.getStatus())) {
            order.setStatus("shipping");
            order.setAcceptedAt(LocalDateTime.now());
            orderMapper.update(order);
        }
    }

    @Transactional
    public void deliverOrder(Long orderId, Long merchantId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getMerchantId().equals(merchantId) && "shipping".equals(order.getStatus())) {
            order.setStatus("delivered");
            order.setDeliveredAt(LocalDateTime.now());
            orderMapper.update(order);
        }
    }

    @Transactional
    public void confirmReceive(Long orderId, Long userId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getUserId().equals(userId) && "delivered".equals(order.getStatus())) {
            order.setStatus("completed");
            order.setCompletedAt(LocalDateTime.now());
            orderMapper.update(order);
        }
    }

    @Transactional
    public void cancelOrder(Long orderId, Long userId) {
        Order order = orderMapper.findById(orderId);
        if (order != null && order.getUserId().equals(userId) && "pending".equals(order.getStatus())) {
            order.setStatus("cancelled");
            orderMapper.updateStatus(order);
        }
    }

    @Transactional
    public Refund applyRefund(Long orderId, Long userId, String reason) {
        Order order = orderMapper.findById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            return null;
        }

        String status = order.getStatus();
        if (!"completed".equals(status) && !"reviewed".equals(status)) {
            return null;
        }

        Refund existingRefund = refundMapper.findByOrderId(orderId);
        if (existingRefund != null) {
            return null;
        }

        if (order.getCompletedAt() != null) {
            long days = ChronoUnit.DAYS.between(order.getCompletedAt(), LocalDateTime.now());
            if (days > 7) {
                return null;
            }
        }

        Refund refund = new Refund();
        refund.setOrderId(orderId);
        refund.setUserId(userId);
        refund.setMerchantId(order.getMerchantId());
        refund.setReason(reason);
        refund.setStatus("pending");
        refundMapper.insert(refund);
        return refund;
    }

    @Transactional
    public void processRefund(Long refundId, Long merchantId, boolean approved, String result) {
        Refund refund = refundMapper.findById(refundId);
        if (refund == null || !refund.getMerchantId().equals(merchantId) || !"pending".equals(refund.getStatus())) {
            return;
        }

        refund.setStatus(approved ? "approved" : "rejected");
        String merchantResultPrefix = approved ? "商家同意退款" : "商家拒绝退款";
        String finalResult = (result == null || result.isBlank()) ? merchantResultPrefix : merchantResultPrefix + "：" + result.trim();
        refund.setResult(finalResult);
        refund.setProcessedAt(LocalDateTime.now());
        refundMapper.update(refund);

        if (approved) {
            Order order = orderMapper.findById(refund.getOrderId());
            if (order != null) {
                order.setStatus("refunded");
                orderMapper.updateStatus(order);
            }
        }
    }

    @Transactional
    public void processRefundByAdmin(Long refundId, boolean approved, String result) {
        Refund refund = refundMapper.findById(refundId);
        if (refund == null || (!"pending".equals(refund.getStatus()) && !"escalated".equals(refund.getStatus()))) {
            return;
        }

        refund.setStatus(approved ? "approved" : "rejected");
        String adminResultPrefix = approved ? "管理员裁定退款成功" : "管理员裁定退款失败";
        String finalResult = (result == null || result.isBlank()) ? adminResultPrefix : adminResultPrefix + "：" + result.trim();
        refund.setResult(finalResult);
        refund.setProcessedAt(LocalDateTime.now());
        refundMapper.update(refund);

        if (approved) {
            Order order = orderMapper.findById(refund.getOrderId());
            if (order != null) {
                order.setStatus("refunded");
                orderMapper.updateStatus(order);
            }
        }
    }

    @Transactional
    public boolean escalateRefundByUser(Long orderId, Long userId, String reason) {
        Refund refund = refundMapper.findByOrderId(orderId);
        if (refund == null || !refund.getUserId().equals(userId) || !"rejected".equals(refund.getStatus())) {
            return false;
        }

        String appendReason = (reason == null || reason.isBlank()) ? "用户申请管理员介入处理" : ("用户申请管理员介入：" + reason.trim());
        String mergedResult;
        if (refund.getResult() == null || refund.getResult().isBlank()) {
            mergedResult = appendReason;
        } else {
            mergedResult = refund.getResult() + "\n" + appendReason;
        }

        refund.setStatus("escalated");
        refund.setResult(mergedResult);
        refund.setProcessedAt(null);
        refundMapper.update(refund);
        return true;
    }
}
