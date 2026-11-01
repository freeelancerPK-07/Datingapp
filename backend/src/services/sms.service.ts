/**
 * Real SMS Gateway Service
 * Supports Fast2SMS (India Best) and Twilio (Global)
 */

interface SendSmsResult {
  success: boolean;
  message?: string;
  error?: string;
}

export async function sendRealOtpSms(phone: string, otp: string): Promise<SendSmsResult> {
  const cleanPhone = phone.replace(/[^0-9]/g, ''); // e.g. 919876543210 -> 9876543210
  const tenDigitPhone = cleanPhone.length > 10 ? cleanPhone.slice(-10) : cleanPhone;

  // 1. FAST2SMS (India Fastest Route)
  const fast2SmsKey = process.env.FAST2SMS_API_KEY;
  if (fast2SmsKey && fast2SmsKey !== 'YOUR_FAST2SMS_API_KEY') {
    try {
      console.log(`[SMS Gateway] Sending real SMS via Fast2SMS to ${tenDigitPhone}...`);
      
      let response = await fetch('https://www.fast2sms.com/dev/bulkV2', {
        method: 'POST',
        headers: {
          authorization: fast2SmsKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          route: 'otp',
          variables_values: otp,
          numbers: tenDigitPhone,
        }),
      });

      let data: any = await response.json();
      console.log('[SMS Gateway] Fast2SMS Response:', data);

      if (data.return !== true && data.status_code !== 200) {
        // Fallback to GET query params
        const getUrl = `https://www.fast2sms.com/dev/bulkV2?authorization=${encodeURIComponent(fast2SmsKey)}&route=otp&variables_values=${encodeURIComponent(otp)}&flash=0&numbers=${encodeURIComponent(tenDigitPhone)}`;
        const getRes = await fetch(getUrl);
        data = await getRes.json();
        console.log('[SMS Gateway] Fast2SMS GET Fallback Response:', data);
      }

      if (data.return === true || data.status_code === 200) {
        return { success: true, message: 'Real SMS delivered to phone' };
      } else {
        return { success: false, error: data.message?.[0] || 'Fast2SMS delivery error' };
      }
    } catch (err: any) {
      console.error('[SMS Gateway] Fast2SMS Network Error:', err.message);
      return { success: false, error: err.message };
    }
  }

  // 2. TWILIO (Global Alternative)
  const twilioSid = process.env.TWILIO_ACCOUNT_SID;
  const twilioAuth = process.env.TWILIO_AUTH_TOKEN;
  const twilioFrom = process.env.TWILIO_PHONE_NUMBER;

  if (twilioSid && twilioAuth && twilioFrom) {
    try {
      console.log(`[SMS Gateway] Sending real SMS via Twilio to +${cleanPhone}...`);
      const authHeader = 'Basic ' + Buffer.from(`${twilioSid}:${twilioAuth}`).toString('base64');
      const params = new URLSearchParams();
      params.append('To', `+${cleanPhone}`);
      params.append('From', twilioFrom);
      params.append('Body', `Your LinkUp verification code is: ${otp}. Valid for 5 minutes.`);

      const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${twilioSid}/Messages.json`, {
        method: 'POST',
        headers: {
          Authorization: authHeader,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString(),
      });

      const data: any = await response.json();
      if (response.ok) {
        return { success: true, message: 'Twilio SMS sent' };
      } else {
        return { success: false, error: data.message };
      }
    } catch (err: any) {
      console.error('[SMS Gateway] Twilio Network Error:', err.message);
      return { success: false, error: err.message };
    }
  }

  // Fallback (Dev Log)
  console.log(`[SMS Gateway - Mock] No API key found. Use terminal OTP or Master OTP 123456. OTP: ${otp}`);
  return { success: true, message: 'Mock OTP logged in console' };
}

