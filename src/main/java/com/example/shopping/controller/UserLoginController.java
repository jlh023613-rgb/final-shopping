package com.example.shopping.controller;

import com.example.shopping.entity.User;
import com.example.shopping.mapper.UserMapper;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.regex.Pattern;

@Controller
public class UserLoginController {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^1[3-9]\\d{9}$");
    private static final Pattern LOWERCASE = Pattern.compile("[a-z]");
    private static final Pattern UPPERCASE = Pattern.compile("[A-Z]");
    private static final Pattern DIGIT = Pattern.compile("[0-9]");
    private static final Pattern SPECIAL = Pattern.compile("[^a-zA-Z0-9]");

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public UserLoginController(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/user/login")
    public String loginPage() {
        return "user/login";
    }

    @PostMapping("/user/login")
    public String login(@RequestParam String phone,
                        @RequestParam String password,
                        HttpSession session) {
        User user = userMapper.findByPhone(phone);
        if (user == null) {
            return "redirect:/user/login?error";
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            return "redirect:/user/login?error";
        }

        session.setAttribute("user", user);
        return "redirect:/";
    }

    @GetMapping("/user/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/user/login?logout";
    }

    @GetMapping("/user/register")
    public String registerPage() {
        return "user/register";
    }

    @PostMapping("/user/register")
    public String register(@RequestParam("username") String username,
                           @RequestParam("phone") String phone,
                           @RequestParam("password") String password,
                           @RequestParam("confirmPassword") String confirmPassword,
                           @RequestParam(value = "gender", defaultValue = "M") String gender,
                           Model model) {
        if (!PHONE_PATTERN.matcher(phone).matches()) {
            model.addAttribute("error", "请输入正确的手机号格式");
            return "user/register";
        }

        if (password.length() < 12 || password.length() > 16) {
            model.addAttribute("error", "密码长度必须在 12 到 16 位之间");
            return "user/register";
        }

        User existingUser = userMapper.findByPhone(phone);
        if (existingUser != null) {
            model.addAttribute("error", "该手机号已经注册");
            return "user/register";
        }

        if (countPasswordTypes(password) <= 1) {
            model.addAttribute("error", "密码强度太弱，请至少包含大小写字母、数字、特殊字符中的两种");
            return "user/register";
        }

        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "两次输入的密码不一致");
            return "user/register";
        }

        User user = new User();
        user.setUsername(username);
        user.setPhone(phone);
        user.setPassword(passwordEncoder.encode(password));
        user.setGender(gender);
        user.setRole("ROLE_USER");
        userMapper.insert(user);

        return "redirect:/user/login?registered";
    }

    private int countPasswordTypes(String password) {
        int types = 0;
        if (LOWERCASE.matcher(password).find()) {
            types++;
        }
        if (UPPERCASE.matcher(password).find()) {
            types++;
        }
        if (DIGIT.matcher(password).find()) {
            types++;
        }
        if (SPECIAL.matcher(password).find()) {
            types++;
        }
        return types;
    }
}
