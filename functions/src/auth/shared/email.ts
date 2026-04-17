import nodemailer from "nodemailer";

export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "n8365989@gmail.com",
    pass: "iojp divi dlul qgyf ",
  },
});