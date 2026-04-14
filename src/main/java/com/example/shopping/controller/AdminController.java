package com.example.shopping.controller;

import com.example.shopping.entity.*;
import com.example.shopping.mapper.*;
import com.example.shopping.service.OrderService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final AdminMapper adminMapper;
    private final MerchantMapper merchantMapper;
    private final ComplaintMapper complaintMapper;
    private final RefundMapper refundMapper;
    private final OrderService orderService;
    private final PasswordEncoder passwordEncoder;

    public AdminController(AdminMapper adminMapper, MerchantMapper merchantMapper,
                           ComplaintMapper complaintMapper, RefundMapper refundMapper,
                           OrderService orderService, PasswordEncoder passwordEncoder) {
        this.adminMapper = adminMapper;
        this.merchantMapper = merchantMapper;
        this.complaintMapper = complaintMapper;
        this.refundMapper = refundMapper;
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
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Merchant> pendingMerchants = merchantMapper.findByStatus("pending");
        List<Merchant> allMerchants = merchantMapper.findAll();
        List<Complaint> pendingComplaints = complaintMapper.findByStatus("pending");
        List<Complaint> allComplaints = complaintMapper.findAll();
        List<Refund> allRefunds = refundMapper.findAll();
        List<Refund> pendingRefunds = allRefunds.stream()
                .filter(r -> "pending".equals(r.getStatus()) || "escalated".equals(r.getStatus()))
                .collect(Collectors.toList());

        long activeMerchants = allMerchants.stream().filter(m -> "approved".equals(m.getStatus())).count();
        long closedMerchants = allMerchants.stream().filter(m -> "closed".equals(m.getStatus())).count();

        model.addAttribute("admin", admin);
        model.addAttribute("pendingMerchants", pendingMerchants.size());
        model.addAttribute("activeMerchants", activeMerchants);
        model.addAttribute("closedMerchants", closedMerchants);
        model.addAttribute("pendingComplaints", pendingComplaints.size());
        model.addAttribute("totalComplaints", allComplaints.size());
        model.addAttribute("pendingRefunds", pendingRefunds.size());
        return "admin/dashboard";
    }

    @GetMapping("/merchants")
    public String merchants(@RequestParam(required = false) String status,
                            HttpSession session, Model model) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Merchant> merchants;
        if (status != null && !status.isEmpty()) {
            merchants = merchantMapper.findByStatus(status);
        } else {
            merchants = merchantMapper.findAll();
        }

        model.addAttribute("admin", admin);
        model.addAttribute("merchants", merchants);
        model.addAttribute("currentStatus", status);
        return "admin/merchants";
    }

    @PostMapping("/merchant/approve/{id}")
    public String approveMerchant(@PathVariable Long id,
                                  @RequestParam String category,
                                  HttpSession session) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && "pending".equals(merchant.getStatus())) {
            merchant.setStatus("approved");
            merchant.setCategory(category);
            merchantMapper.updateStatus(merchant);
            merchantMapper.updateCategory(merchant);
        }
        return "redirect:/admin/merchants?status=pending";
    }

    @PostMapping("/merchant/reject/{id}")
    public String rejectMerchant(@PathVariable Long id, HttpSession session) {
        Admin admin = (Admin) session.getAttribute("admin");
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
    public String closeMerchant(@PathVariable Long id, HttpSession session) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && "approved".equals(merchant.getStatus())) {
            merchant.setStatus("closed");
            merchantMapper.updateStatus(merchant);
        }
        return "redirect:/admin/merchants";
    }

    @PostMapping("/merchant/reopen/{id}")
    public String reopenMerchant(@PathVariable Long id, HttpSession session) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Merchant merchant = merchantMapper.findById(id);
        if (merchant != null && "closed".equals(merchant.getStatus())) {
            merchant.setStatus("approved");
            merchantMapper.updateStatus(merchant);
        }
        return "redirect:/admin/merchants";
    }

    @GetMapping("/complaints")
    public String complaints(@RequestParam(required = false) String status,
                             HttpSession session, Model model) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Complaint> complaints;
        if (status != null && !status.isEmpty()) {
            complaints = complaintMapper.findByStatus(status);
        } else {
            complaints = complaintMapper.findAll();
        }

        model.addAttribute("admin", admin);
        model.addAttribute("complaints", complaints);
        model.addAttribute("currentStatus", status);
        return "admin/complaints";
    }

    @GetMapping("/order-list")
    public String orderList(HttpSession session, Model model) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Order> orders = orderService.findAll();
        model.addAttribute("admin", admin);
        model.addAttribute("orders", orders);
        return "admin/order-list";
    }

    @PostMapping("/complaint/handle/{id}")
    public String handleComplaint(@PathVariable Long id,
                                  @RequestParam String result,
                                  @RequestParam(required = false, defaultValue = "false") boolean closeShop,
                                  HttpSession session) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        Complaint complaint = complaintMapper.findById(id);
        if (complaint != null && "pending".equals(complaint.getStatus())) {
            complaint.setStatus("handled");
            String finalResult = (result == null || result.isBlank()) ? "管理员已处理投诉" : result.trim();
            if (closeShop) {
                finalResult = finalResult + "（店铺已关停）";
            } else {
                finalResult = finalResult + "（店铺未关停）";
            }
            complaint.setResult(finalResult);
            complaintMapper.updateResult(complaint);

            if (closeShop) {
                Merchant merchant = merchantMapper.findById(complaint.getMerchantId());
                if (merchant != null) {
                    merchant.setStatus("closed");
                    merchantMapper.updateStatus(merchant);
                }
            }
        }
        return "redirect:/admin/complaints";
    }

    @GetMapping("/refunds")
    public String refunds(HttpSession session, Model model) {
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        List<Refund> refunds = refundMapper.findAll();
        List<Refund> pendingRefunds = refunds.stream()
                .filter(r -> "pending".equals(r.getStatus()) || "escalated".equals(r.getStatus()))
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
        Admin admin = (Admin) session.getAttribute("admin");
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
        Admin admin = (Admin) session.getAttribute("admin");
        if (admin == null) {
            return "redirect:/admin/login";
        }

        orderService.processRefundByAdmin(id, false, result);
        return "redirect:/admin/refunds";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/admin/login";
    }
}
