-- call transcripts generated with gpt-3.5
CREATE TABLE IF NOT EXISTS customer_support_transcripts (
    call_id STRING NOT NULL PRIMARY KEY,
    customer_id STRING NOT NULL,
    agent_id STRING NOT NULL,
    call_start_timestamp TIMESTAMP_LTZ NOT NULL,
    call_end_timestamp TIMESTAMP_LTZ NOT NULL,
    call_duration_seconds NUMBER,
    transcript TEXT,
    sentiment_score FLOAT,
    call_reason STRING,
    product_related STRING,
    resolution_status STRING,
    feedback_rating NUMBER(1),
    feedback_comments TEXT,
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO customer_support_transcripts (
    call_id, customer_id, agent_id, call_start_timestamp, call_end_timestamp, transcript, sentiment_score, call_reason, product_related, resolution_status, feedback_rating, feedback_comments
) 
VALUES
('006', 'C105', 'A13', '2023-08-16 09:00:00', '2023-08-16 09:10:00', 'pending', 0.5, 'Baggage Inquiry', 'Excess Baggage Charges', 'Pending', NULL, NULL),
('007', 'C106', 'A14', '2023-08-16 10:00:00', '2023-08-16 10:10:00', 'pending', 0.7, 'Flight Delay', 'Compensation', 'Pending', NULL, NULL),
('008', 'C107', 'A15', '2023-08-16 11:00:00', '2023-08-16 11:10:00', 'pending', -0.2, 'Booking Inquiry', 'Seat Preference', 'Pending', NULL, NULL),
('009', 'C108', 'A13', '2023-08-16 12:00:00', '2023-08-16 12:10:00', 'pending', 0.6, 'Cancellation', 'Refund Process', 'Pending', NULL, NULL),
('010', 'C109', 'A16', '2023-08-16 01:00:00', '2023-08-16 01:10:00', 'pending', 0.4, 'Feedback', 'In-flight Services', 'Pending', NULL, NULL),
('011', 'C110', 'A17', '2023-08-16 02:00:00', '2023-08-16 02:10:00', 'pending', -0.3, 'Loyalty Program', 'Miles Redemption', 'Pending', NULL, NULL),
('012', 'C111', 'A18', '2023-08-16 03:00:00', '2023-08-16 03:10:00', 'pending', 0.8, 'Seat Upgrade', 'Business Class', 'Pending', NULL, NULL),
('013', 'C112', 'A19', '2023-08-16 04:00:00', '2023-08-16 04:10:00', 'pending', 0.5, 'Check-in Inquiry', 'Online Check-in', 'Pending', NULL, NULL),
('014', 'C113', 'A20', '2023-08-16 05:00:00', '2023-08-16 05:10:00', 'pending', 0.7, 'Feedback', 'Cabin Crew Service', 'Pending', NULL, NULL),
('015', 'C114', 'A14', '2023-08-16 06:00:00', '2023-08-16 06:10:00', 'pending', 0.9, 'In-flight Meals', 'Dietary Restrictions', 'Pending', NULL, NULL);

UPDATE customer_support_transcripts 
SET transcript = 
    '**Customer:** Hello, I\'ve recently traveled with your airline, flight number AA2456, and I had a couple of issues I wanted to address.
**Representative:** Good day! I\'m sorry to hear that you had issues with your recent flight. Could you please provide me with your booking reference or ticket number so I can pull up the details?
**Customer:** Sure, it\'s 12345678XYZ.
**Representative:** Thank you. Give me a moment to pull up the information... Alright, I see your details here. Please go ahead and explain the issues you faced.
**Customer:** Firstly, my flight was delayed by over 3 hours. It really disrupted my plans at my destination. And then, when I finally boarded, my pre-selected seat which I paid extra for was taken, and I was given a different seat.
**Representative:** I apologize for the inconvenience caused. Delays can be quite frustrating, and the seat mix-up shouldn\'t have happened either. Let me check the reason for the delay first... Alright, the delay was due to unforeseen maintenance issues, and we understand the impact it can have on our passengers\' plans.
**Customer:** Maintenance issues? That\'s concerning. And what about my seat?
**Representative:** I\'m looking into it now. From the records, it seems there was a last-minute aircraft change, which led to a reset in seat allocation. I understand it\'s not an ideal situation, especially since you paid extra for a preferred seat. As a goodwill gesture, I can offer you a voucher for a future flight or a refund for the extra amount you paid for your seat. Which would you prefer?
**Customer:** I appreciate that. I\'ll take the voucher. And is there a way I can be informed earlier if there\'s an issue with my seat or flight in the future?
**Representative:** Absolutely. We do have a notification system in place that sends out emails and text messages in case of changes or issues with your flight. Perhaps you didn\'t opt in for notifications when booking? I can help you set it up now if you\'d like.
**Customer:** Yes, please. That would be helpful. 
**Representative:** Alright, I\'ve set you up for notifications. You\'ll receive an email and a text message for any changes related to your future bookings. And regarding the voucher, I\'ve issued it to your account. You\'ll get an email confirmation shortly.
**Customer:** Thank you for addressing my concerns. I hope I don\'t encounter such issues in the future.
**Representative:** I understand, and I sincerely apologize for the inconvenience you faced. We always strive to provide the best service, and your feedback helps us improve. Thank you for bringing this to our attention, and safe travels on your future journeys.
**Customer:** Thanks. Goodbye.
**Representative:** Goodbye and take care.'
WHERE call_id = '006';

UPDATE customer_support_transcripts 
SET transcript = 
'**Customer:** Hi, I booked a flight from New York to Paris for October 15th, but I didn\'t receive a confirmation email.\n
**Representative:** I\'m sorry for the inconvenience. Can I have your booking reference number, please?\n
**Customer:** Yes, it\'s ABCD1234.\n
**Representative:** Thank you. I see your booking. It looks like the email was sent to john.doe@example.com. Is that the correct email address?\n
**Customer:** Oh, I made a typo. It should be john.doe@exampel.com.\n
**Representative:** I see. Let me update that for you and resend the confirmation email. Please check your inbox in a few minutes.\n
**Customer:** Thank you. Also, can I request a vegetarian meal for the flight?\n
**Representative:** Of course! I\'ve added a request for a vegetarian meal to your booking. Anything else I can assist with?\n
**Customer:** That\'s all for now. Thank you for your help!\n
**Representative:** You\'re welcome. Safe travels!\n'
WHERE id = '007';

UPDATE customer_support_transcripts 
SET transcript = 
    '**Customer:** Hello, I recently booked a flight from New York to London on your website. I just realized I mistakenly selected the wrong date. It should be for the 12th of September, not the 2nd. Can you help?\n
    **Representative:** Of course, I apologize for any inconvenience. Let me check the availability on the 12th of September for you. Can you provide your booking reference number, please?\n
    **Customer:** Yes, it\'s A1B2C3.\n
    **Representative:** Thank you. I found your booking. Give me a moment to see the options for the 12th.\n
    **Customer:** No problem, thank you for the help.\n
    **Representative:** I\'m glad to inform you that we have seats available on the 12th. However, there\'s a slight difference in the fare. Would you like me to go ahead and make the change for you?\n
    **Customer:** Yes, that would be great. How much is the difference?\n
    **Representative:** The difference is $50. Would that be acceptable?\n
    **Customer:** Yes, that\'s fine. Please make the change.\n
    **Representative:** Perfect, I\'ve successfully changed your booking date to the 12th of September. You will be charged an additional $50. Is there anything else I can assist you with?\n
    **Customer:** No, that\'s it. Thank you for your help!\n
    **Representative:** You\'re welcome! Safe travels, and thank you for choosing our airline. Have a great day!\n
    **Customer:** You too! Goodbye.\n
    **Representative:** Goodbye!'
WHERE id = '008';

UPDATE customer_support_transcripts 
SET transcript = 
    '**Customer:** Hi, I was on Flight AC456 from Paris to Tokyo yesterday and I left my laptop in the overhead compartment. I\'m really worried about it. Can you help me?\n
    **Representative:** I\'m sorry to hear that. Let me assist you. Can you provide your seat number and the make/model of your laptop, so I can check with our lost and found department?\n
    **Customer:** I was in seat 18C. It\'s a Dell XPS 15 with a silver cover.\n
    **Representative:** Thank you for the details. Please wait a moment while I check for you.\n
    **Customer:** Thank you, I really hope it\'s been found.\n
    **Representative:** I have good news! Your laptop was found by our cleaning crew and it has been kept safely in our lost and found. You can pick it up from our airport office at Terminal 3, Desk 45.\n
    **Customer:** Oh, that\'s a relief! Thank you so much. How long will you hold it for me?\n
    **Representative:** We will hold items for 30 days. However, I recommend picking it up as soon as possible to ensure its safety. Would you like directions to our office?\n
    **Customer:** Yes, that would be great. And thank you again, this means a lot.\n
    **Representative:** It\'s no problem at all. To reach our office, once you enter Terminal 3, go towards the check-in counters and you\'ll see signs for "Airline Help Desks". We\'re at Desk 45. Someone will be there to assist you. Safe travels and take care!\n
    **Customer:** Will do! Thanks again and have a great day.\n
    **Representative:** You too! Let us know if you need any further assistance. Goodbye!'
WHERE id = '009';


UPDATE customer_support_transcripts 
SET transcript = 
    '**Customer:** I\'ve been a loyal customer of your airline for over a decade, but my recent experiences have left me extremely disappointed. I\'m seriously considering never flying with you again.\n
    **Representative:** I\'m truly sorry to hear that you feel this way. Your loyalty means a lot to us. Can you please tell me what happened so I can try to assist you?\n
    **Customer:** Last month, I faced a six-hour delay without any satisfactory explanation. And just last week, I had the worst in-flight experience. The entertainment system was down, and the food was below par. It\'s not the airline I once loved.\n
    **Representative:** I apologize deeply for these experiences. We always aim to provide the best service, and I regret that we fell short in your recent travels. While I can\'t change the past, I\'d love to find a way to make it right moving forward. Would you be open to discussing compensation or other ways to rectify this?\n
    **Customer:** I appreciate your efforts, but it\'s not just about compensation. It\'s about the trust and reliability I once had with your airline. I travel frequently for business, and these inconsistencies make my journeys stressful.\n
    **Representative:** I understand, and I\'m genuinely sorry for the challenges you\'ve faced. Our airline values each of our passengers, especially long-time loyal customers like you. We\'ll certainly take your feedback and work on our shortcomings. I wish there was something I could do to change your mind right now.\n
    **Customer:** I believe actions speak louder than words. Maybe it\'s time for me to explore other airlines that prioritize customer experience more consistently.\n
    **Representative:** I respect your decision and am truly sorry to see you go. Your feedback is invaluable, and I promise we\'ll use it to improve. Should you ever decide to give us another chance, please know that we\'re committed to making it a positive experience.\n
    **Customer:** I\'ll think about it. For now, I need a break from your airline. Goodbye.\n
    **Representative:** I understand. Take care, and thank you for the years of trust. If you ever wish to discuss anything in the future, we\'re here to listen. Goodbye.'
WHERE id = '010';

UPDATE customer_support_transcripts
SET transcript = 
'**Customer:** Hi there, I have a flight scheduled for tomorrow morning, and I wanted to inquire about the baggage allowance.
**Representative:** Hello! I\'d be happy to help you with that. Could you please provide me with your booking reference or the flight number?
**Customer:** Sure, my booking reference is ABC123.
**Representative:** Thank you for providing that. Let me check the details for your flight. Please bear with me for a moment.
*Representative is checking the customer\'s booking.*
**Representative:** I appreciate your patience. Your flight from New York to London allows for one carry-on bag and one checked bag as part of the standard economy fare. Additional baggage may incur extra charges. Is there anything specific you\'d like to know about the baggage policy?
**Customer:** That\'s great, thank you for the information. I also wanted to know if I can request a vegetarian meal due to my dietary preferences.
**Representative:** Of course, we can definitely assist you with that. May I have your full name, please?
**Customer:** My name is Emily Johnson.
**Representative:** Thank you, Emily. I\'ve noted down your request for a vegetarian meal. This information will be passed on to the catering team, and they will do their best to accommodate your preference.
**Customer:** Perfect, thanks for your help!
**Representative:** You\'re welcome! If you have any more questions or need further assistance, feel free to reach out. Have a pleasant flight and a great day!
**Customer:** Thank you, I appreciate it. Goodbye!
**Representative:** Goodbye, Emily. Take care and have a wonderful journey!
'
WHERE id = '011';

UPDATE customer_support_transcripts
SET transcript = 
'**Customer:** Hi there, I have a flight scheduled for tomorrow morning and I wanted to inquire about changing the date of my flight.
**Representative:** Hello! I\'d be happy to assist you with that. Can you please provide me with your booking reference or the flight number?
**Customer:** Of course, my booking reference is XYZ456.
**Representative:** Thank you for providing that. Let me pull up your booking details. One moment, please.
*Representative is reviewing the customer\'s booking.*
**Representative:** Thank you for waiting. I see that youre currently booked on a flight from Los Angeles to Chicago. Changing the date of your flight is subject to availability and fare conditions. May I know your preferred new date of travel?
**Customer:** I\'d like to change it to next Friday, if possible.
**Representative:** Understood. Let me check if there are available seats on the flight next Friday. Please bear with me for a moment.
*Representative is checking seat availability for the requested date.*
**Representative:** Good news! There are seats available for the flight next Friday. However, please note that changing the date of your flight might result in a fare difference. Would you like to proceed with the change?
**Customer:** Yes, that sounds good. I understand there might be a fare difference.
**Representative:** Perfect. I\'ve successfully changed the date of your flight from Los Angeles to Chicago to next Friday. The fare difference is $50, which you can pay when confirming the change. An email with the updated itinerary and payment details will be sent to you shortly.
**Customer:** Great, thank you for your help!
**Representative:** You\'re welcome! If you have any more questions or need further assistance, feel free to ask. Have a wonderful flight next Friday!
**Customer:** Thank you, I appreciate your assistance. Goodbye!
**Representative:** Goodbye! If you need anything else in the future, don\'t hesitate to reach out. Have a fantastic day!'
WHERE id = '012';

UPDATE customer_support_transcripts
SET transcript = 
'**Customer:** Hi, I\'m having an issue with my flight reservation and I need some assistance.
**Representative:** Hello! I\'m here to help you. Could you please provide me with your booking reference or flight number?
**Customer:** Sure, my booking reference is GHI012.
**Representative:** Thank you. Let me retrieve your booking information. Please give me a moment.
*Representative is looking up the customer\'s booking details.*
**Representative:** I appreciate your patience. I\'ve located your reservation for the upcoming flight from Chicago to Denver. What seems to be the issue?
**Customer:** I accidentally selected the wrong title during booking. It should be "Mr." instead of "Mrs."
**Representative:** No worries, mistakes happen. I can certainly update that for you. Could you please confirm the correct title, "Mr.," for your reservation?
**Customer:** Yes, that\'s correct. It should be "Mr."
**Representative:** Thank you. I\'ve made the necessary correction to your title. It will now appear as "Mr." on your booking. Is there anything else you\'d like to address?
**Customer:** That\'s all, thank you for fixing that for me.
**Representative:** You\'re welcome! If you have any more questions or need further assistance, don\'t hesitate to reach out. Have a great flight and enjoy your trip!
**Customer:** Thanks, I appreciate your help. Have a wonderful day!
**Representative:** Thank you! You too, have a fantastic day and safe travels!
'
WHERE id = '013';

UPDATE customer_support_transcripts
SET transcript = 
'**Customer:** Hello, I need to make a change to my existing reservation.
**Representative:** Hi there! I\'m here to help. Could you please provide me with your booking reference or flight number?
**Customer:** Certainly, my booking reference is DEF789.
**Representative:** Thank you for providing that. Let me retrieve your booking details. One moment, please.
*Representative is looking up the customer\'s booking.*
**Representative:** Thanks for waiting. I\'ve found your reservation for the flight from Miami to Dallas. What change would you like to make?
**Customer:** I need to change the return date to a week later.
**Representative:** Noted. Let me check the availability for the new return date. Please bear with me for a moment.
*Representative is checking flight availability.*
**Representative:** Good news! There are seats available for the requested return date. I\'ve successfully updated your reservation. However, please be aware that there might be a fare difference. Are you okay with that?
**Customer:** Yes, I understand. A fare difference is fine.
**Representative:** Great! I\'ve made the changes to your reservation. The fare difference is $75, which will be charged to the original payment method. You\'ll receive an updated itinerary via email shortly.
**Customer:** Thank you so much for your assistance!
**Representative:** You\'re welcome! If you have any more questions or need further help, feel free to ask. Have a smooth and pleasant journey!
**Customer:** I appreciate your help. Have a wonderful day!
**Representative:** Thank you! You too, have a fantastic day and a safe trip!
'
WHERE id = '014';