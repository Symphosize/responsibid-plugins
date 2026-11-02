Sequence seq-1 "Quote follow-up" — merge fields in scope: {Contact.FirstName}, {Company.Name}, {Bid.ProposalLink}
- step-1 (EMAIL) Subject: Your quote | Body: {Contact.FirstName}, your quote is ready: {Bid.ProposalLink}. Reply if you have questions. - {Company.Name}
- step-2 (SMS) Body: Hi {Contact.FirstName}, following up on your quote. {Bid.ProposalLink}
