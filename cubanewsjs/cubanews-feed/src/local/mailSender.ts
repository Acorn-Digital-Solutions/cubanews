import "server-only";

import * as nodemailer from "nodemailer";
import moment from "moment";
import cubanewsApp from "@/app/cubanewsApp";

const from = "cubanews.icu@gmail.com";

export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "cubanews.icu@gmail.com",
    pass: process.env.MAIL_PWD,
  },
});

export async function sendEmails() {
  const recipients = await cubanewsApp.getRecipients();
  if (recipients.length === 0) {
    return;
  }
  const today = moment();
  const mailOptions = {
    from: from,
    to: "",
    bcc: recipients.join(";"),
    subject: `CubaNews resumen ${today.format("LL")}`,
    html: await cubanewsApp.getEmailBody(),
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error("Error occurred:", error);
    } else {
      console.log("Email sent:", info.response);
    }
  });
}

(async () => {
  try {
    await sendEmails();
  } catch (error) {
    console.error("Error sending emails ", error);
  }
})();
