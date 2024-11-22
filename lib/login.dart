import 'package:flutter/material.dart';
import 'package:my_reminder_app/controllers/general_controller.dart';
import 'package:my_reminder_app/functionality_widget/enum.dart';
import 'package:my_reminder_app/screen/dashboard.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool isvisible = false;

  bool islogintrue = false;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(builder: (context, AuthProvider authProvider, child) {
        return SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 100),

                Image.asset(
                  "assets/logo_sekolah.png",
                  width: 210,
                ),

                const SizedBox(height: 20),
                //Username
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xff7EB8BF).withOpacity(.3)),
                  child: TextFormField(
                    style: const TextStyle(fontFamily: "Poppins"),

                    controller: username,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "username is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      border: InputBorder.none,
                      hintText: "Username",
                    ),
                  ),
                ),

                //Password
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xff7EB8BF).withOpacity(.3)),
                  child: TextFormField(
                    style: const TextStyle(fontFamily: "Poppins"),
                    controller: password,
                    
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "password is required";
                      }
                      return null;
                    },
                    obscureText: !isvisible,
                    
                    decoration: InputDecoration(
                      
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Password",
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                //toggle button
                                isvisible = !isvisible;
                              });
                            },
                            icon: Icon(isvisible
                                ? Icons.visibility
                                : Icons.visibility_off))),
                  ),
                ),

                const SizedBox(height: 10),
                //login button
                Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xff7EB8BF)),
                  child: TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // Trigger login
                          await authProvider.loginWithEmailAndPassword(
                            username.text,
                            password.text,
                          );

                          if (authProvider.loadingState ==
                              LoadingState.success) {
                            // Navigate to another page or show success message
                            print('Login successful');
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  const Dashboard()),
                            );
                          } else if (authProvider.loadingState ==
                              LoadingState.error) {
                            // Show error message
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, 
                        fontFamily: "Poppins", fontWeight: FontWeight.w700
                        ),
                      )),
                ),

                //Sign up button
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text("Don't have an account?"),
                    // TextButton(
                    //     onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => RegisterScreen()),
                    //         );
                    //       //Navigate to sign up
                    //     },
                    //     child: const Text("Sign Up"))
                  ],
                ),

                if (authProvider.loadingState == LoadingState.loading)
                  const CircularProgressIndicator(),
                if (authProvider.loadingState == LoadingState.error)
                  const Text('Login failed, please try again.'),
              ],
            ),
          ),
        );
      }),
    );
  }
}
