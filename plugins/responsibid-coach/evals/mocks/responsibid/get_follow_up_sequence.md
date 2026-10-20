Sequence seq-1 "Quote follow-up" — merge fields in scope: {Contact.FirstName}, {Company.Name}, {Bid.ProposalLink}

Step step-1 (EMAIL, 1 day after quote)
Subject: Your quote
Body: {Contact.FirstName}, your quote is ready: {Bid.ProposalLink}. Reply if you have questions. - {Company.Name}

Step step-2 (SMS, 3 days after quote)
Body: Hi {Contact.FirstName}, following up on your quote. {Bid.ProposalLink}
