package com.example.shopping.controller;

import com.example.shopping.entity.AbnormalOrderRecord;
import com.example.shopping.entity.Admin;
import com.example.shopping.entity.Complaint;
import com.example.shopping.entity.Merchant;
import com.example.shopping.entity.Product;
import com.example.shopping.entity.Refund;
import com.example.shopping.mapper.AdminMapper;
import com.example.shopping.mapper.ComplaintMapper;
import com.example.shopping.mapper.MerchantMapper;
import com.example.shopping.mapper.ProductMapper;
import com.example.shopping.mapper.RefundMapper;
import com.example.shopping.service.OrderService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private static final DateTimeFormatter CLOSE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final AdminMapper adminMapper;
    private final MerchantMapper merchantMapper;
    private final ComplaintMapper complaintMapper;
    private final RefundMapper refundMapper;
    private final ProductMapper productMapper;
    private final OrderService orderService;
    private final PasswordEncoder passwordEncoder;

    public AdminController(AdminMapper adminMapper,
                           MerchantMapper merchantMapper,
                           ComplaintMapper complaintMapper,
                           RefundMapper refundMapper,
                           ProductMapper productMapper,
                           OrderService orderService,
                           PasswordEncoder passwordEncoder) {
        this.adminMapper = adminMapper;
        this.merchantMapper = merchantMapper;
        this.complaintMapper = complaintMapper;
        this.refundMapper = refundMapper;
        this.productMapper = productMapper;
        this.orderService = orderService;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/login")
    public String loginPage() {
        return "admin/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        HttpSession session) {
        Admin admin = adminMapper.findByUsername(username);
        if (admin == null) {
            return "redirect:/admin/login?error";
        }
        if (!passwordEncoder.matches(password, admin.getPassword())) {
            return "redirect:/admin/login?error";
        }

        session.setAttribute("admin", admin);
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Merchant> allMerchants = refreshExpiredClosures(merchantMapper.findAll());
        List<Merchant> pendingMerchants = allMerchants.stream()
                .filter(merchant -> "pending".equals(merchant.getStatus()))
                .collect(Collectors.toList());
        List<Complaint> pendingComplaints = complaintMapper.findByStatus("pending");
        List<Complaint> allComplaints = complaintMapper.findAll();
        List<Refund> allRefunds = refundMapper.findAll();
        List<Refund> pendingRefunds = allRefunds.stream()
                .filter(this::isUnhandledRefund)
                .collect(Collectors.toList());
        List<Product> pendingProducts = productMapper.findMerchantApplicationsByStatus(0);

        long activeMerchants = allMerchants.stream().filter(m -> "approved".equals(m.getStatus())).count();
        long closedMerchants = allMerchants.stream().filter(m -> "closed".equals(m.getStatus())).count();

        model.addAttribute("admin", admin);
        model.addAttribute("pendingMerchants", pendingMerchants.size());
        model.addAttribute("activeMerchants", activeMerchants);
        model.addAttribute("closedMerchants", closedMerchants);
        model.addAttribute("pendingComplaints", pendingComplaints.size());
        model.addAttribute("totalComplaints", allComplaints.size());
        model.addAttribute("pendingRefunds", pendingRefunds.size());
        model.addAttribute("pendingProducts", pendingProducts.size());
        return "admin/dashboard";
    }

    @GetMapping("/merchants")
    public String merchants(@RequestParam(required = false) String status,
                            HttpSession session,
                            Model model) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Merchant> merchants = refreshExpiredClosures((status != null && !status.isEmpty())
                ? merchantMapper.findByStatus(status)
                : merchantMapper.findAll());

        model.addAttribute("admin", admin);
        model.addAttribute("merchants", merchants);
        model.addAttribute("currentStatus", status);
        return "admin/merchants";
    }

    @PostMapping("/merchant/approve/{id}")
    public String approveMerchant(@PathVariable Long id,
                                  @RequestParam String category,
                                  HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && "pending".equals(merchant.getStatus())) {
            merchant.setStatus("approved");
            merchant.setCategory(category);
            merchantMapper.updateStatus(merchant);
            merchantMapper.updateCategory(merchant);
            merchantMapper.clearClosure(merchant.getId());
        }
        return "redirect:/admin/merchants?status=pending";
    }

    @PostMapping("/merchant/reject/{id}")
    public String rejectMerchant(@PathVariable Long id, HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && "pending".equals(merchant.getStatus())) {
            merchant.setStatus("rejected");
            merchantMapper.updateStatus(merchant);
        }
        return "redirect:/admin/merchants?status=pending";
    }

    @PostMapping("/merchant/close/{id}")
    public String closeMerchant(@PathVariable Long id,
                                @RequestParam String closeReason,
                                @RequestParam(defaultValue = "7d") String closeDuration,
                                HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && ("approved".equals(merchant.getStatus()) || "closed".equals(merchant.getStatus()))) {
            applyMerchantClosure(merchant, closeReason, closeDuration);
        }
        return "redirect:/admin/merchants";
    }

    @PostMapping("/merchant/reopen/{id}")
    public String reopenMerchant(@PathVariable Long id, HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && "closed".equals(merchant.getStatus())) {
            merchantMapper.clearClosure(merchant.getId());
        }
        return "redirect:/admin/merchants";
    }

    @GetMapping("/complaints")
    public String complaints(@RequestParam(required = false) String status,
                             HttpSession session,
                             Model model) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Complaint> complaints = (status != null && !status.isEmpty())
                ? complaintMapper.findByStatus(status)
                : complaintMapper.findAll();

        model.addAttribute("admin", admin);
        model.addAttribute("complaints", complaints);
        model.addAttribute("currentStatus", status);
        return "admin/complaints";
    }

    @GetMapping("/order-list")
    public String orderList(HttpSession session, Model model) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<AbnormalOrderRecord> abnormalOrders = buildAbnormalOrders();
        for (int i = 0; i < abnormalOrders.size(); i++) {
            abnormalOrders.get(i).setSerialNo(i + 1);
        }

        model.addAttribute("admin", admin);
        model.addAttribute("abnormalOrders", abnormalOrders);
        return "admin/order-list";
    }

    @PostMapping("/complaint/handle/{id}")
    public String handleComplaint(@PathVariable Long id,
                                  @RequestParam String result,
                                  @RequestParam(required = false, defaultValue = "false") boolean closeShop,
                                  @RequestParam(required = false) String closeReason,
                                  @RequestParam(defaultValue = "7d") String closeDuration,
                                  HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Complaint complaint = complaintMapper.findById(id);
        if (complaint != null && "pending".equals(complaint.getStatus())) {
            complaint.setStatus("handled");
            String finalResult = (result == null || result.isBlank()) ? "管理员已处理该投诉" : result.trim();
            if (closeShop) {
                Merchant merchant = merchantMapper.findById(complaint.getMerchantId());
                if (merchant != null) {
                    applyMerchantClosure(merchant, closeReason, closeDuration);
                    finalResult = finalResult
                            + "（店铺已关停，关停时长："
                            + describeCloseDuration(closeDuration)
                            + "，恢复时间："
                            + merchant.getCloseUntil().format(CLOSE_TIME_FORMATTER)
                            + "，原因："
                            + merchant.getCloseReason()
                            + "）";
                }
            } else {
                finalResult = finalResult + "（店铺未关停）";
            }
            complaint.setResult(finalResult);
            complaintMapper.updateResult(complaint);
        }
        return "redirect:/admin/complaints";
    }

    @GetMapping("/refunds")
    public String refunds(HttpSession session, Model model) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Refund> refunds = refundMapper.findAll();
        List<Refund> pendingRefunds = refunds.stream()
                .filter(this::isUnhandledRefund)
                .collect(Collectors.toList());

        model.addAttribute("admin", admin);
        model.addAttribute("refunds", refunds);
        model.addAttribute("pendingRefunds", pendingRefunds);
        return "admin/refunds";
    }

    @PostMapping("/refund/approve/{id}")
    public String approveRefund(@PathVariable Long id,
                                @RequestParam(required = false) String result,
                                HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        orderService.processRefundByAdmin(id, true, result);
        return "redirect:/admin/refunds";
    }

    @PostMapping("/refund/reject/{id}")
    public String rejectRefund(@PathVariable Long id,
                               @RequestParam String result,
                               HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        orderService.processRefundByAdmin(id, false, result);
        return "redirect:/admin/refunds";
    }

    @GetMapping("/product-applications")
    public String productApplications(@RequestParam(required = false) Integer status,
                                      HttpSession session,
                                      Model model) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Product> products = productMapper.findMerchantApplicationsByStatus(status);
        model.addAttribute("admin", admin);
        model.addAttribute("products", products);
        model.addAttribute("currentStatus", status);
        return "admin/product-applications";
    }

    @PostMapping("/product-application/approve/{id}")
    public String approveProductApplication(@PathVariable Long id, HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Product product = productMapper.findById(id);
        if (product != null && product.getMerchantId() != null && Integer.valueOf(0).equals(product.getStatus())) {
            productMapper.updateAuditStatus(product.getId(), 1, "管理员已审核通过", LocalDateTime.now());
        }
        return "redirect:/admin/product-applications?status=0";
    }

    @PostMapping("/product-application/reject/{id}")
    public String rejectProductApplication(@PathVariable Long id,
                                           @RequestParam String auditReason,
                                           HttpSession session) {
        Admin admin = requireAdmin(session);
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Product product = productMapper.findById(id);
        if (product != null && product.getMerchantId() != null && Integer.valueOf(0).equals(product.getStatus())) {
            String finalReason = (auditReason == null || auditReason.isBlank()) ? "管理员未通过该商品申请" : auditReason.trim();
            productMapper.updateAuditStatus(product.getId(), -1, finalReason, LocalDateTime.now());
        }
        return "redirect:/admin/product-applications?status=0";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/admin/login";
    }

    private Admin requireAdmin(HttpSession session) {
        return (Admin) session.getAttribute("admin");
    }

    private boolean isUnhandledRefund(Refund refund) {
        return "pending".equals(refund.getStatus()) || "escalated".equals(refund.getStatus());
    }

    private void applyMerchantClosure(Merchant merchant, String closeReason, String closeDuration) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime baseTime = merchant.getCloseUntil() != null && merchant.getCloseUntil().isAfter(now)
                ? merchant.getCloseUntil()
                : now;

        merchant.setStatus("closed");
        merchant.setCloseReason((closeReason == null || closeReason.isBlank())
                ? "管理员暂时关停店铺，请根据平台要求整改后恢复营业"
                : closeReason.trim());
        merchant.setCloseUntil(resolveCloseUntil(baseTime, closeDuration));
        merchant.setClosedAt(now);
        merchantMapper.updateClosure(merchant);
    }

    private List<AbnormalOrderRecord> buildAbnormalOrders() {
        List<AbnormalOrderRecord> abnormalOrders = new ArrayList<>();

        for (Complaint complaint : complaintMapper.findAll()) {
            AbnormalOrderRecord record = new AbnormalOrderRecord();
            record.setType("投诉");
            record.setSourceId(complaint.getId());
            record.setShopName(defaultText(complaint.getMerchantShopName()));
            record.setProductName(defaultText(complaint.getProductName()));
            record.setIssue("投诉：" + defaultText(complaint.getContent()));
            record.setHandled("handled".equals(complaint.getStatus()));
            record.setStatusText("handled".equals(complaint.getStatus()) ? "已处理" : "未处理");
            record.setTargetUrl("/admin/complaints" + ("handled".equals(complaint.getStatus()) ? "?status=handled" : "?status=pending"));
            record.setResult(complaint.getResult());
            record.setCreatedAt(complaint.getCreatedAt());
            abnormalOrders.add(record);
        }

        for (Refund refund : refundMapper.findAll()) {
            boolean handled = !isUnhandledRefund(refund);
            AbnormalOrderRecord record = new AbnormalOrderRecord();
            record.setType("退款");
            record.setSourceId(refund.getId());
            record.setShopName(defaultText(refund.getMerchantShopName()));
            record.setProductName(defaultText(refund.getProductName()));
            record.setIssue("退款：" + defaultText(refund.getReason()));
            record.setHandled(handled);
            record.setStatusText(handled ? "已处理" : "未处理");
            record.setTargetUrl("/admin/refunds");
            record.setResult(refund.getResult());
            record.setCreatedAt(refund.getCreatedAt());
            abnormalOrders.add(record);
        }

        abnormalOrders.sort(
                Comparator.comparing((AbnormalOrderRecord record) -> Boolean.TRUE.equals(record.getHandled()))
                        .thenComparing(AbnormalOrderRecord::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder()))
        );
        return abnormalOrders;
    }

    private String defaultText(String value) {
        return (value == null || value.isBlank()) ? "-" : value.trim();
    }

    private List<Merchant> refreshExpiredClosures(List<Merchant> merchants) {
        return merchants.stream()
                .map(this::refreshMerchantStatusIfNeeded)
                .collect(Collectors.toList());
    }

    private Merchant refreshMerchantStatusIfNeeded(Merchant merchant) {
        if (merchant == null || !"closed".equals(merchant.getStatus())) {
            return merchant;
        }
        if (merchant.getCloseUntil() != null && !merchant.getCloseUntil().isAfter(LocalDateTime.now())) {
            merchantMapper.clearClosure(merchant.getId());
            Merchant refreshed = merchantMapper.findById(merchant.getId());
            return refreshed != null ? refreshed : merchant;
        }
        return merchant;
    }

    private LocalDateTime resolveCloseUntil(LocalDateTime baseTime, String closeDuration) {
        return switch (closeDuration) {
            case "1d" -> baseTime.plusDays(1);
            case "1m" -> baseTime.plusMonths(1);
            case "3m" -> baseTime.plusMonths(3);
            case "1y" -> baseTime.plusYears(1);
            case "7d" -> baseTime.plusDays(7);
            default -> baseTime.plusDays(7);
        };
    }

    private String describeCloseDuration(String closeDuration) {
        return switch (closeDuration) {
            case "1d" -> "1天";
            case "1m" -> "1个月";
            case "3m" -> "3个月";
            case "1y" -> "1年";
            case "7d" -> "7天";
            default -> "7天";
        };
    }
}
