package com.example.shopping.controller;

import com.example.shopping.entity.Address;
import com.example.shopping.entity.User;
import com.example.shopping.mapper.AddressMapper;
import com.example.shopping.mapper.CartMapper;
import com.example.shopping.mapper.UserMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class UserCenterController {

    private final UserMapper userMapper;
    private final AddressMapper addressMapper;
    private final CartMapper cartMapper;
    private final PasswordEncoder passwordEncoder;

    public UserCenterController(UserMapper userMapper, AddressMapper addressMapper, CartMapper cartMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.addressMapper = addressMapper;
        this.cartMapper = cartMapper;
        this.passwordEncoder = passwordEncoder;
    }

    private User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }

    @GetMapping("/center")
    public String userCenter(HttpSession session, Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }
        List<Address> addresses = addressMapper.findByUserId(user.getId());
        
        model.addAttribute("user", user);
        model.addAttribute("addresses", addresses);
        return "user/center";
    }

    @GetMapping({"/address", "/addresses"})
    public String addressEntry(HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }
        // Address management is embedded in user center.
        return "redirect:/user/center";
    }

    @PostMapping("/address/add")
    public String addAddress(HttpSession session,
                            @RequestParam String receiverName,
                            @RequestParam String receiverPhone,
                            @RequestParam String province,
                            @RequestParam String city,
                            @RequestParam String district,
                            @RequestParam String detailAddress,
                            @RequestParam(defaultValue = "false") Boolean isDefault) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }
        
        if (isDefault) {
            addressMapper.clearDefault(user.getId());
        }
        
        Address address = new Address();
        address.setUserId(user.getId());
        address.setReceiverName(receiverName);
        address.setReceiverPhone(receiverPhone);
        address.setProvince(province);
        address.setCity(city);
        address.setDistrict(district);
        address.setDetailAddress(detailAddress);
        address.setIsDefault(isDefault);
        addressMapper.insert(address);
        
        return "redirect:/user/center";
    }

    @PostMapping("/address/delete/{id}")
    public String deleteAddress(@PathVariable Long id, HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }
        
        Address address = addressMapper.findById(id);
        if (address != null && address.getUserId().equals(user.getId())) {
            addressMapper.delete(id);
        }
        
        return "redirect:/user/center";
    }

    @PostMapping("/address/default/{id}")
    public String setDefaultAddress(@PathVariable Long id, HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }
        
        Address address = addressMapper.findById(id);
        if (address != null && address.getUserId().equals(user.getId())) {
            addressMapper.clearDefault(user.getId());
            addressMapper.setDefault(id, user.getId());
        }
        
        return "redirect:/user/center";
    }

    @PostMapping("/delete")
    public String deleteAccount(@RequestParam String confirmPhone,
                               @RequestParam String confirmPassword,
                               HttpSession session,
                               RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }
        
        if (!confirmPhone.equals(user.getPhone())) {
            redirectAttributes.addFlashAttribute("error", "手机号不匹配");
            return "redirect:/user/center";
        }
        
        if (!passwordEncoder.matches(confirmPassword, user.getPassword())) {
            redirectAttributes.addFlashAttribute("error", "密码不正确");
            return "redirect:/user/center";
        }
        
        cartMapper.deleteByUserId(user.getId());
        addressMapper.deleteByUserId(user.getId());
        userMapper.delete(user.getId());
        session.invalidate();
        
        return "redirect:/user/login";
    }

    @PostMapping("/verify-password")
    @ResponseBody
    public Map<String, Object> verifyPassword(@RequestParam String password,
                                              HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = getCurrentUser(session);
        if (user == null) {
            result.put("success", false);
            result.put("message", "请先登录");
            return result;
        }
        
        if (passwordEncoder.matches(password, user.getPassword())) {
            result.put("success", true);
        } else {
            result.put("success", false);
            result.put("message", "密码错误");
        }
        
        return result;
    }
}
