**Farm2Fork**

**Project Master Context Document**

Transparent Agriculture Supply Chain Platform

Version 1.0 | Spring 2026 | Group SE-3

| **Field**               | **Details**                                                                                    |
| ----------------------- | ---------------------------------------------------------------------------------------------- |
| Project                 | Farm2Fork - Transparent Agriculture Supply Chain Platform                                      |
| Document type           | Project Master Context - read by all agents across all repos                                   |
| Version                 | 1.0                                                                                            |
| Group                   | SE-3 \| University of Central Punjab \| FoIT&CS                                                |
| Advisor / Product Owner | Ali Haider Arif                                                                                |
| Scrum Master            | Muhammad Junaid Afzal                                                                          |
| Team                    | Muhammad Junaid Afzal, Muhammad Qaim Raza, Syed Muhammad Abdullah Askari                       |
| Repos                   | farm2fork-mobile \| farm2fork-backend \| farm2fork-web \| farm2fork-ai \| farm2fork-blockchain |
| Last updated            | May 2026                                                                                       |

This document is the single source of truth for all agents working on Farm2Fork. Every agent, regardless of which repo they are working in, must read this document before writing any code, making any architectural decision, or modifying any schema field.

# **1\. Purpose and Authority of This Document**

Farm2Fork is a multi-repo project developed by a 3-person team with significant assistance from AI coding agents. Each repo has its own ruleset. This document sits above all individual rulesets and provides the shared context, architecture decisions, data model, and cross-repo contracts that all agents must understand and respect.

⚠ Individual repo rulesets define how to build within that repo. This document defines what is being built and why. Conflicts between a repo ruleset and this document must be raised with the project owner - not silently resolved by the agent.

**Document authority hierarchy:**

- This document - Project Master Context
- Individual repo ruleset (e.g. Agent Development Ruleset v1.1 for mobile)
- In-conversation instructions from the project owner
- Agent judgment

# **2\. What is Farm2Fork**

Farm2Fork is a blockchain-backed, AI-enhanced digital platform that directly connects Pakistani farmers to buyers - eliminating exploitative middlemen while ensuring supply chain transparency, fair pricing, financial inclusion, and end-to-end delivery management.

## **2.1 The Problem**

Pakistan's agricultural sector contributes 20-24% to GDP and employs over 35% of the labour force, yet small-scale farmers are among the most economically vulnerable people in the country. The core problems are:

- Farmers sell through intermediaries who take large margins, leaving farmers with below-market prices and no visibility into what buyers actually pay
- Buyers - retailers, restaurants, wholesalers - cannot verify produce quality, origin, or authenticity, creating trust deficits and food safety risks
- Smallholders lack formal banking history, barring them from credit and loans that could improve productivity
- No single platform in the Pakistani market combines direct marketplace, blockchain traceability, AI pricing, microfinance, and transport management

## **2.2 The Solution**

Farm2Fork addresses all of these simultaneously in one integrated platform:

| **Module**              | **What it does**                                                               | **Who benefits**      |
| ----------------------- | ------------------------------------------------------------------------------ | --------------------- |
| Marketplace             | Direct farm-to-buyer listings, search, browse, cart, checkout                  | Farmers + Buyers      |
| Blockchain Traceability | Hyperledger Fabric records every supply chain event; QR codes for verification | Buyers + Consumers    |
| AI Price & Quality      | FastAPI ML service predicts fair prices and grades quality                     | Farmers               |
| Order & Payment         | JazzCash/Stripe payment gateway, platform fee (percentage-based), receipts     | Farmers + Buyers      |
| Transport Module        | Shipment assignment to transport partners, real-time status tracking           | Buyers + Transporters |
| Microfinance            | Loan applications for farmers, reviewed by financial partners                  | Farmers               |
| Admin Panel             | User management, audit logs, loan review, system config                        | Administrators        |
| Community               | Posts and comments for knowledge sharing among farmers and buyers              | Farmers + Buyers      |

## **2.3 Scrutiny Committee Feedback - Addressed**

The idea defence committee raised the following concerns in January 2026. All have been addressed:

| **Committee concern**                                  | **How Farm2Fork addresses it**                                                                                                                                  |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Similar products already exist (Agriconnect, Farmease) | Farm2Fork differentiates through the combination of blockchain traceability + AI pricing + microfinance + transport - no existing local competitor has all four |
| Should add transportation module                       | Transport module added as EP-07 with US-16 (shipment management) and US-17 (delivery tracking) - fully designed and in sprint plan                              |
| Need distinct features                                 | Blockchain journey timeline, QR verification, AI price advisor with confidence score, and loan application flow are distinct from existing platforms            |

# **3\. Repository Structure**

The project uses a GitHub Organisation with 5 separate repositories. Locally, these are combined in a single workspace so agents have full cross-repo context.

| **Repo**             | **Tech stack**                                   | **Owner**                                                 | **Purpose**                                                                        |
| -------------------- | ------------------------------------------------ | --------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| farm2fork-mobile     | Flutter, Dart, Riverpod, go_router, Dio, Freezed | Muhammad Qaim Raza (UI/UX) + Muhammad Junaid Afzal (lead) | Cross-platform mobile app for Android - farmer, buyer, and transport partner flows |
| farm2fork-backend    | Nest.js (Node.js), MongoDB, Redis                | Syed Muhammad Abdullah Askari + Muhammad Junaid Afzal     | Main API server - modular monolith with one module per epic                        |
| farm2fork-web        | Next.js, React, TypeScript                       | Muhammad Qaim Raza                                        | Admin panel - web interface for system admin and financial partners                |
| farm2fork-ai         | Python, FastAPI, scikit-learn / PyTorch          | Muhammad Junaid Afzal                                     | AI microservice - price prediction and quality assessment endpoints                |
| farm2fork-blockchain | Hyperledger Fabric 2.5, Go chaincode             | Muhammad Junaid Afzal                                     | Blockchain network - transaction recording and supply chain event ledger           |

## **3.1 Docker Architecture**

All services run in Docker containers orchestrated by Docker Compose for local development. The same images are used for cloud deployment.

| **Container** | **Image**                   | **Exposes** | **Purpose**                                                    |
| ------------- | --------------------------- | ----------- | -------------------------------------------------------------- |
| f2f-nginx     | nginx:alpine                | 80, 443     | Reverse proxy - routes external traffic to Nest.js and Next.js |
| f2f-nestjs    | node:20-alpine              | 3000        | Main backend - all Nest.js modules                             |
| f2f-nextjs    | node:20-alpine              | 3001        | Admin web panel                                                |
| f2f-fastapi   | python:3.11-slim            | 8000        | AI service - price prediction and quality assessment           |
| f2f-mongodb   | mongo:7                     | 27017       | Primary database                                               |
| f2f-redis     | redis:7-alpine              | 6379        | Caching layer                                                  |
| f2f-fabric    | hyperledger/fabric-peer:2.5 | 7051        | Blockchain peer node                                           |

Nest.js calls FastAPI over the Docker internal network (<http://f2f-fastapi:8000>). No external HTTP. Nest.js calls Hyperledger Fabric SDK directly - Fabric does not expose an HTTP endpoint to other services.

# **4\. System Architecture**

## **4.1 Architecture Style - Modular Monolith + Separate AI Service**

Farm2Fork uses a Modular Monolith for the Nest.js backend. This means one deployable application with internally separated modules, each with its own controllers, services, and repositories. Modules communicate in-process, not over HTTP. The AI service is the only true separate service - it runs as a separate FastAPI container because Python is the right tool for ML and Node.js is not.

⚠ Agents must not propose splitting the Nest.js backend into microservices. The modular monolith was chosen deliberately for a 3-person team on a 2-semester timeline. Microservices would not be completed in time.

## **4.2 Nest.js Module Structure**

Each Nest.js module maps to one Epic from the product backlog:

| **Module**         | **Epic**      | **Responsibility**                                                    |
| ------------------ | ------------- | --------------------------------------------------------------------- |
| AuthModule         | EP-01         | Registration, login, JWT, password reset, RBAC guards                 |
| MarketplaceModule  | EP-02         | Product listings, search, filter, QR code generation                  |
| OrderModule        | EP-04         | Order creation, one-order-one-farmer enforcement, order status        |
| PaymentModule      | EP-04         | JazzCash/Stripe integration, platform fee calculation, payment status |
| BlockchainModule   | EP-03         | Hyperledger Fabric SDK calls, transaction recording, retry logic      |
| TraceabilityModule | EP-03         | QR verification, supply chain event recording, blockchain journey     |
| AIModule           | EP-05         | HTTP client calling FastAPI - price suggestions, quality assessment   |
| TransportModule    | EP-07         | Shipment assignment, status updates, delivery tracking                |
| LoanModule         | EP-06         | Loan applications, repayment schedules, financial partner review      |
| AdminModule        | EP-08         | User management, audit logs, system config                            |
| CommunityModule    | EP-09         | Posts, comments, community feed                                       |
| NotificationModule | Cross-cutting | FCM push notifications, in-app notification records                   |

# **5\. Database Schema - 17 Collections**

MongoDB is the primary database. All 17 collections are listed below with their full schemas. Agents must not rename, add, or remove fields without explicit approval from the project owner.

⚠ These schemas are the contract between the backend and all clients (mobile app, web admin, AI service). Any change here must be coordinated across all repos simultaneously.

## **5.1 users**

| **Field**    | **Type**      | **Notes**                                                                                    |
| ------------ | ------------- | -------------------------------------------------------------------------------------------- |
| \_id         | ObjectId      | MongoDB primary key                                                                          |
| email        | String        | Unique, indexed                                                                              |
| passwordHash | String        | bcrypt hashed - never exposed to any client                                                  |
| role         | String (enum) | farmer \| buyer \| transporter \| financial_partner \| admin - these exact values, no others |
| phone        | String        |                                                                                              |
| isVerified   | Boolean       | Default: false - email verification required                                                 |
| isActive     | Boolean       | Default: true - admin can deactivate                                                         |
| fcmToken     | String        | Firebase Cloud Messaging token - never logged or exposed                                     |
| createdAt    | Date          |                                                                                              |
| updatedAt    | Date          |                                                                                              |

## **5.2 farmer_profiles**

| **Field**          | **Type**   | **Notes**                                                         |
| ------------------ | ---------- | ----------------------------------------------------------------- |
| \_id               | ObjectId   |                                                                   |
| userId             | ObjectId   | Ref: users - unique index                                         |
| farmName           | String     |                                                                   |
| farmLocation       | Object     | { lat, lng, address, city, province }                             |
| cropTypes          | \[String\] | e.g. \['wheat', 'tomatoes', 'mangoes'\]                           |
| landSizeAcres      | Number     |                                                                   |
| cnic               | String     | Unique, indexed - sensitive, never logged                         |
| certifications     | \[Object\] | { name, issuedBy, issuedDate, expiryDate, documentUrl }           |
| bankAccountDetails | Object     | { bankName, accountNumber, accountTitle } - sensitive, mask in UI |
| createdAt          | Date       |                                                                   |
| updatedAt          | Date       |                                                                   |

## **5.3 buyer_profiles**

| **Field**    | **Type**      | **Notes**                                          |
| ------------ | ------------- | -------------------------------------------------- |
| \_id         | ObjectId      |                                                    |
| userId       | ObjectId      | Ref: users - unique index                          |
| businessName | String        |                                                    |
| businessType | String (enum) | individual \| retailer \| restaurant \| wholesaler |
| addresses    | \[Object\]    | { label, street, city, province, zip, isDefault }  |
| cnic         | String        | Unique, indexed - sensitive                        |
| createdAt    | Date          |                                                    |
| updatedAt    | Date          |                                                    |

## **5.4 transporter_profiles**

| **Field**     | **Type**      | **Notes**                                               |
| ------------- | ------------- | ------------------------------------------------------- |
| \_id          | ObjectId      |                                                         |
| userId        | ObjectId      | Ref: users - unique index                               |
| vehicleType   | String (enum) | bike \| rickshaw \| van \| truck                        |
| vehicleNumber | String        |                                                         |
| licenseNumber | String        | Sensitive                                               |
| cnic          | String        | Unique, indexed - sensitive                             |
| serviceAreas  | \[String\]    | Cities/regions covered, e.g. \['Lahore', 'Faisalabad'\] |
| isAvailable   | Boolean       | Default: true                                           |
| createdAt     | Date          |                                                         |
| updatedAt     | Date          |                                                         |

## **5.5 financial_partner_profiles**

| **Field**       | **Type**      | **Notes**                                      |
| --------------- | ------------- | ---------------------------------------------- |
| \_id            | ObjectId      |                                                |
| userId          | ObjectId      | Ref: users - unique index                      |
| institutionName | String        | e.g. 'Akhuwat Foundation', 'Bank of Punjab'    |
| institutionType | String (enum) | bank \| microfinance \| ngo \| government      |
| licenseNumber   | String        | Regulatory license - sensitive                 |
| cnic            | String        | Unique, indexed - sensitive                    |
| designation     | String        | e.g. 'Loan Officer'                            |
| approvalLimit   | Number        | Max loan amount this partner can approve (PKR) |
| serviceRegions  | \[String\]    | Provinces/cities they serve                    |
| createdAt       | Date          |                                                |
| updatedAt       | Date          |                                                |

## **5.6 products**

| **Field**                 | **Type**      | **Notes**                                                                                                                     |
| ------------------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| \_id                      | ObjectId      |                                                                                                                               |
| farmerId                  | ObjectId      | Ref: users (role: farmer) - indexed                                                                                           |
| name                      | String        |                                                                                                                               |
| category                  | String        | e.g. vegetables \| fruits \| grains \| dairy                                                                                  |
| description               | String        |                                                                                                                               |
| price                     | Number        | Per unit in PKR                                                                                                               |
| quantity                  | Number        |                                                                                                                               |
| unit                      | String (enum) | kg \| ton \| dozen \| piece \| litre                                                                                          |
| images                    | \[String\]    | Cloud storage URLs                                                                                                            |
| qualityGrade              | String (enum) | A \| B \| C                                                                                                                   |
| qrCode                    | String        | Generated URL - unique index                                                                                                  |
| initialBlockchainRecordId | ObjectId      | Ref: blockchain_transactions - first traceability record on listing. NOTE: old name was blockchainTxId - that name is retired |
| status                    | String (enum) | active \| inactive \| sold_out                                                                                                |
| createdAt                 | Date          |                                                                                                                               |
| updatedAt                 | Date          |                                                                                                                               |

## **5.7 orders**

⚠ One-Order-One-Farmer Rule: every order belongs to exactly one farmer. All items in orders.items\[\] must belong to the same farmerId. The cart must group products by farmer. Checkout creates one order per farmer group. This is enforced at the OrderService layer - any request creating a mixed-farmer order is rejected with 400 Bad Request.

| **Field**          | **Type**      | **Notes**                                                                                           |
| ------------------ | ------------- | --------------------------------------------------------------------------------------------------- |
| \_id               | ObjectId      |                                                                                                     |
| buyerId            | ObjectId      | Ref: users (role: buyer) - indexed                                                                  |
| farmerId           | ObjectId      | Ref: users (role: farmer) - indexed. All items must belong to this farmer.                          |
| items              | \[Object\]    | Embedded: { productId, farmerId, productName (snapshot), quantity, unitPrice (snapshot), subtotal } |
| totalAmount        | Number        | Sum of all item subtotals                                                                           |
| platformFeePercent | Number        | Copied from system_config at order time - percentage-based                                          |
| platformFeeAmount  | Number        | Calculated: totalAmount × (platformFeePercent / 100)                                                |
| grandTotal         | Number        | totalAmount + platformFeeAmount                                                                     |
| shippingAddress    | Object        | { street, city, province, zip } - copied from buyer address at order time                           |
| status             | String (enum) | pending \| paid \| processing \| shipped \| delivered \| cancelled                                  |
| paymentId          | ObjectId      | Ref: payments                                                                                       |
| shipmentId         | ObjectId      | Ref: shipments                                                                                      |
| createdAt          | Date          |                                                                                                     |
| updatedAt          | Date          |                                                                                                     |

## **5.8 payments**

| **Field**      | **Type**      | **Notes**                                                       |
| -------------- | ------------- | --------------------------------------------------------------- |
| \_id           | ObjectId      |                                                                 |
| orderId        | ObjectId      | Ref: orders - unique index                                      |
| buyerId        | ObjectId      | Ref: users                                                      |
| amount         | Number        | grandTotal from order                                           |
| currency       | String        | Default: PKR                                                    |
| gateway        | String (enum) | jazzcash \| stripe                                              |
| gatewayRef     | String        | External transaction ID - sensitive, do not expose to non-admin |
| status         | String (enum) | pending \| success \| failed \| refunded                        |
| blockchainTxId | ObjectId      | Ref: blockchain_transactions - recorded after success           |
| paidAt         | Date          | Nullable - populated when status becomes success                |
| failedAt       | Date          | Nullable - populated when status becomes failed                 |
| refundedAt     | Date          | Nullable - populated when status becomes refunded               |
| createdAt      | Date          |                                                                 |
| updatedAt      | Date          |                                                                 |

## **5.9 blockchain_transactions**

⚠ Payload fields are sanitised typed sub-documents. Do not expose raw payload to normal users. Payment metadata (bank details, gateway internals) must never appear in buyer-facing or farmer-facing API responses.

| **Field**           | **Type**       | **Notes**                                                                                                            |
| ------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------- |
| \_id                | ObjectId       |                                                                                                                      |
| type                | String (enum)  | payment \| supply_chain_event                                                                                        |
| referenceId         | ObjectId       | Polymorphic ref - points to Payment or Shipment or Product                                                           |
| referenceModel      | String (enum)  | Payment \| Shipment \| Product                                                                                       |
| txHash              | String         | Hyperledger Fabric transaction hash - unique index                                                                   |
| blockNumber         | Number         |                                                                                                                      |
| channelName         | String         | Fabric channel name                                                                                                  |
| payload.payment     | Object or null | { orderId, buyerId, farmerId, amount, currency, gateway, paidAt } - populated for type: payment                      |
| payload.supplyChain | Object or null | { productId, farmerId, eventType, location, actorId, actorRole, timestamp } - populated for type: supply_chain_event |
| status              | String (enum)  | pending \| confirmed \| failed                                                                                       |
| retryCount          | Number         | Default: 0, max: 3                                                                                                   |
| createdAt           | Date           | Immutable - no updatedAt on this collection                                                                          |

## **5.10 shipments**

| **Field**         | **Type**      | **Notes**                                                                                                                         |
| ----------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| \_id              | ObjectId      |                                                                                                                                   |
| orderId           | ObjectId      | Ref: orders - unique index                                                                                                        |
| transporterId     | ObjectId      | Ref: users (role: transporter)                                                                                                    |
| status            | String (enum) | assigned \| picked_up \| in_transit \| delivered \| failed                                                                        |
| pickupAddress     | Object        | { street, city, province } - farmer's farm location                                                                               |
| deliveryAddress   | Object        | { street, city, province, zip } - copied from order shippingAddress                                                               |
| statusHistory     | \[Object\]    | { status, timestamp, note, updatedBy } - updatedBy is ref: users. Timeline UI must be built from this array, not hardcoded steps. |
| estimatedDelivery | Date          |                                                                                                                                   |
| actualDelivery    | Date          | Nullable - populated on delivered                                                                                                 |
| createdAt         | Date          |                                                                                                                                   |
| updatedAt         | Date          |                                                                                                                                   |

## **5.11 loan_applications**

| **Field**         | **Type**      | **Notes**                                                        |
| ----------------- | ------------- | ---------------------------------------------------------------- |
| \_id              | ObjectId      |                                                                  |
| applicantId       | ObjectId      | Ref: users - ROLE MUST BE farmer. Buyers cannot apply for loans. |
| amount            | Number        | Requested amount in PKR                                          |
| purpose           | String        | e.g. 'Buy seeds', 'Equipment purchase'                           |
| durationMonths    | Number        | Repayment period in months                                       |
| status            | String (enum) | pending \| under_review \| approved \| rejected \| repaid        |
| reviewedBy        | ObjectId      | Ref: users (role: financial_partner)                             |
| reviewNote        | String        |                                                                  |
| documents         | \[String\]    | Uploaded file URLs - sensitive, CNIC and land documents          |
| repaymentSchedule | \[Object\]    | { dueDate, amount, isPaid, paidAt }                              |
| createdAt         | Date          |                                                                  |
| updatedAt         | Date          |                                                                  |

## **5.12 audit_logs**

⚠ Immutable - no updatedAt. Admin-only access. Never expose to non-admin users. metadata.before and metadata.after may contain sensitive state - sanitize before returning even to admin.

| **Field**       | **Type** | **Notes**                                                              |
| --------------- | -------- | ---------------------------------------------------------------------- |
| \_id            | ObjectId |                                                                        |
| actorId         | ObjectId | Ref: users                                                             |
| actorRole       | String   | Role at time of action                                                 |
| action          | String   | Dot-notation e.g. user.deactivated \| product.deleted \| loan.approved |
| targetEntity    | String   | e.g. 'User' \| 'Product' \| 'LoanApplication'                          |
| targetId        | ObjectId |                                                                        |
| metadata.before | Object   | State before action                                                    |
| metadata.after  | Object   | State after action                                                     |
| ipAddress       | String   |                                                                        |
| createdAt       | Date     | Immutable                                                              |

## **5.13 posts**

| **Field**    | **Type**      | **Notes**                                                            |
| ------------ | ------------- | -------------------------------------------------------------------- |
| \_id         | ObjectId      |                                                                      |
| authorId     | ObjectId      | Ref: users (role: farmer or buyer)                                   |
| title        | String        |                                                                      |
| content      | String        |                                                                      |
| images       | \[String\]    | Cloud storage URLs                                                   |
| tags         | \[String\]    |                                                                      |
| commentCount | Number        | Denormalized counter - increment on new comment, decrement on delete |
| status       | String (enum) | published \| removed                                                 |
| createdAt    | Date          |                                                                      |
| updatedAt    | Date          |                                                                      |

## **5.14 comments**

| **Field**       | **Type**      | **Notes**                                                                                    |
| --------------- | ------------- | -------------------------------------------------------------------------------------------- |
| \_id            | ObjectId      |                                                                                              |
| postId          | ObjectId      | Ref: posts - indexed                                                                         |
| authorId        | ObjectId      | Ref: users                                                                                   |
| content         | String        |                                                                                              |
| parentCommentId | ObjectId      | Null for MVP. Field exists to support nested replies in the future without schema migration. |
| status          | String (enum) | active \| removed                                                                            |
| createdAt       | Date          |                                                                                              |
| updatedAt       | Date          |                                                                                              |

## **5.15 notifications**

| **Field**          | **Type**      | **Notes**                                                                                                |
| ------------------ | ------------- | -------------------------------------------------------------------------------------------------------- |
| \_id               | ObjectId      |                                                                                                          |
| userId             | ObjectId      | Ref: users - indexed                                                                                     |
| type               | String (enum) | order_placed \| payment_confirmed \| shipment_assigned \| delivery_update \| loan_update \| admin_action |
| title              | String        | Short notification title                                                                                 |
| message            | String        | Full notification body                                                                                   |
| relatedEntityId    | ObjectId      | Polymorphic - points to Order, Shipment, LoanApplication etc.                                            |
| relatedEntityModel | String        | e.g. 'Order' \| 'Shipment' \| 'LoanApplication'                                                          |
| isRead             | Boolean       | Default: false                                                                                           |
| createdAt          | Date          |                                                                                                          |

## **5.16 ai_predictions**

| **Field**         | **Type**      | **Notes**                                                   |
| ----------------- | ------------- | ----------------------------------------------------------- |
| \_id              | ObjectId      |                                                             |
| userId            | ObjectId      | Ref: users (role: farmer) - indexed                         |
| productId         | ObjectId      | Ref: products                                               |
| predictionType    | String (enum) | price \| quality                                            |
| inputData         | Object        | { productName, category, quantity, unit, location, season } |
| predictedMinPrice | Number        | PKR - populated for price predictions                       |
| predictedMaxPrice | Number        | PKR - populated for price predictions                       |
| qualityGrade      | String (enum) | A \| B \| C - populated for quality predictions             |
| confidenceScore   | Number        | 0.0 to 1.0                                                  |
| modelVersion      | String        | e.g. 'price-v1.2' - tracked for model evaluation            |
| createdAt         | Date          |                                                             |

## **5.17 system_config**

⚠ Never access this collection directly from any client. All reads must go through ConfigService on the backend. ConfigService validates and types the value before returning it. Raw config documents are admin-only.

| **Field**   | **Type** | **Notes**                                                                                                  |
| ----------- | -------- | ---------------------------------------------------------------------------------------------------------- |
| \_id        | ObjectId |                                                                                                            |
| key         | String   | Unique index. Known keys: platform_fee_percent \| max_loan_amount \| min_loan_amount \| supported_gateways |
| value       | Mixed    | Type depends on key - validated by ConfigService. platform_fee_percent is always Number.                   |
| description | String   | Human-readable explanation of what this key controls                                                       |
| updatedBy   | ObjectId | Ref: users (role: admin only)                                                                              |
| updatedAt   | Date     |                                                                                                            |

## **5.18 Critical Indexes**

| **Collection**             | **Field(s)**        | **Index type** |
| -------------------------- | ------------------- | -------------- |
| users                      | email               | Unique         |
| farmer_profiles            | userId, cnic        | Unique         |
| buyer_profiles             | userId, cnic        | Unique         |
| transporter_profiles       | userId              | Unique         |
| financial_partner_profiles | userId, cnic        | Unique         |
| products                   | farmerId + status   | Compound       |
| products                   | qrCode              | Unique         |
| orders                     | buyerId + status    | Compound       |
| orders                     | farmerId + status   | Compound       |
| blockchain_transactions    | txHash              | Unique         |
| shipments                  | orderId             | Unique         |
| comments                   | postId              | Standard       |
| notifications              | userId + isRead     | Compound       |
| ai_predictions             | userId + productId  | Compound       |
| audit_logs                 | actorId + createdAt | Compound       |
| system_config              | key                 | Unique         |

# **6\. Critical Business Rules**

These rules are non-negotiable. Every agent in every repo must understand and enforce them.

## **6.1 One-Order-One-Farmer Rule**

⚠ This is the most important business rule. Violating it breaks the payment, shipment, and farmer ledger flows.

One order belongs to exactly one farmer. This means:

- orders.farmerId identifies the single farmer for the entire order
- Every item in orders.items\[\] must have a productId whose farmerId matches orders.farmerId
- The cart must group products by farmer - if a buyer adds products from two farmers, that is two separate cart groups
- Checkout creates one order per farmer group - two farmer groups means two API calls, two orders, two payments
- OrderService.createOrder() validates this before persisting - mixed-farmer requests return 400 Bad Request
- The mobile cart UI must clearly show farmer-grouped sections and create separate orders per group

## **6.2 Platform Fee - Percentage Based**

Farm2Fork charges a percentage-based platform fee on every order. The percentage is stored in system_config with key 'platform_fee_percent'. At order creation time:

- platformFeePercent is read from ConfigService (not directly from system_config)
- platformFeeAmount = totalAmount × (platformFeePercent / 100)
- grandTotal = totalAmount + platformFeeAmount
- Both platformFeePercent and platformFeeAmount are stored on the order document as a snapshot - changes to system_config do not retroactively affect existing orders

## **6.3 Loan Applications - Farmers Only**

Microfinance loan applications are restricted to users with role: farmer. Users with role buyer, transporter, financial_partner, or admin cannot submit loan applications. This is enforced at the LoanService layer with a role guard. The original user stories document incorrectly labelled this as a customer feature - that was a documentation error, now corrected.

## **6.4 Blockchain Recording - Triggered Events**

Blockchain recording is not manual. It is triggered automatically by these events:

- Payment success → PaymentService triggers BlockchainModule to record payment event
- Product listed → MarketplaceService triggers BlockchainModule to record first supply chain event (stored as initialBlockchainRecordId on the product)
- Shipment status changes → TransportService triggers BlockchainModule for each supply chain event

Blockchain recording is asynchronous - it must not block the primary API response. If recording fails, it retries up to 3 times (retryCount field). Persistent failure is logged but does not reverse the order or payment.

## **6.5 Notification Triggers**

Notifications are created server-side and pushed via Firebase Cloud Messaging (FCM). The following events trigger notifications:

| **Event**                                                  | **Notified users**                       | **Notification type** |
| ---------------------------------------------------------- | ---------------------------------------- | --------------------- |
| Order placed successfully                                  | Farmer (new order), Buyer (confirmation) | order_placed          |
| Payment confirmed                                          | Buyer                                    | payment_confirmed     |
| Shipment assigned to transporter                           | Buyer, Transporter                       | shipment_assigned     |
| Shipment status updated (picked up, in transit, delivered) | Buyer                                    | delivery_update       |
| Loan application status changed                            | Farmer (applicant)                       | loan_update           |
| Admin deactivates user account                             | Affected user                            | admin_action          |

## **6.6 Sensitive Fields - Never Expose**

⚠ These fields must never appear in any API response sent to non-admin clients, any log file, any error message, or any UI component.

| **Field**             | **Collection**                                   | **Why sensitive**                             |
| --------------------- | ------------------------------------------------ | --------------------------------------------- |
| passwordHash          | users                                            | Authentication credential                     |
| fcmToken              | users                                            | Device identifier - privacy                   |
| cnic                  | All profile collections                          | National ID - mask last 4 digits if displayed |
| bankAccountDetails    | farmer_profiles                                  | Financial credential - mask account number    |
| licenseNumber         | transporter_profiles, financial_partner_profiles | Regulatory document                           |
| gatewayRef            | payments                                         | Payment gateway internal reference            |
| payload internals     | blockchain_transactions                          | May contain payment metadata                  |
| metadata.before/after | audit_logs                                       | May contain any sensitive state               |
| documents URLs        | loan_applications                                | Private uploaded documents                    |

# **7\. Cross-Repo API Contract**

## **7.1 Backend → Mobile / Web**

The Nest.js backend exposes a REST API consumed by both the Flutter mobile app and the Next.js admin panel. All endpoints:

- Return JSON
- Use JWT Bearer token authentication (Authorization: Bearer &lt;token&gt;)
- Use role-based guards - endpoints are restricted to the roles listed in the use case table
- Attach Accept-Language header from client - Dio interceptor on mobile, fetch interceptor on web
- Return consistent error structure: { statusCode, message, error }

## **7.2 Backend → AI Service**

Nest.js calls FastAPI over the Docker internal network. Communication is synchronous HTTP. The AI service does not call back to Nest.js.

| **Endpoint**                              | **Method** | **Called by**       | **Purpose**                            |
| ----------------------------------------- | ---------- | ------------------- | -------------------------------------- |
| <http://f2f-fastapi:8000/predict/price>   | POST       | AIModule (Nest.js)  | Returns price prediction for a product |
| <http://f2f-fastapi:8000/predict/quality> | POST       | AIModule (Nest.js)  | Returns quality grade for a product    |
| <http://f2f-fastapi:8000/health>          | GET        | Docker health check | Service availability                   |

After receiving a prediction, AIModule saves the result to the ai_predictions collection. This is intentional - predictions are stored for model evaluation, history display, and to demonstrate to evaluators that the AI module is functional.

## **7.3 Backend → Hyperledger Fabric**

BlockchainModule uses the Hyperledger Fabric Node.js SDK to submit transactions directly to the Fabric network. This is not HTTP - it is a direct gRPC connection to the Fabric peer node via the SDK. The Fabric network does not expose any HTTP endpoints.

## **7.4 Mobile App Language Header**

The Flutter mobile app attaches the selected locale to every API request via a Dio interceptor:

Accept-Language: en

Accept-Language: ur

The backend may use this header to return localised error messages. The frontend must not depend on the backend for basic UI strings - all static labels use ARB localisation files.

# **8\. Mobile App - farm2fork-mobile**

## **8.1 Tech Stack - Locked**

| **Technology**   | **Package / Version**                      | **Purpose**                                         |
| ---------------- | ------------------------------------------ | --------------------------------------------------- |
| Framework        | Flutter (latest stable)                    | Cross-platform mobile - Android primary, iOS future |
| Language         | Dart                                       |                                                     |
| State management | Riverpod                                   | Feature-level providers, async state                |
| Routing          | go_router                                  | Named routes, auth redirects, deep linking          |
| Networking       | Dio                                        | HTTP client with interceptors                       |
| Data models      | Freezed + json_serializable                | Immutable typed models, JSON parsing                |
| Code generation  | build_runner                               | Generates .freezed.dart and .g.dart files           |
| Localisation     | flutter_localizations (SDK) + intl ^0.20.2 | Official Flutter SDK localisation stack             |
| Linting          | flutter_lints                              |                                                     |

⚠ The following are explicitly forbidden in farm2fork-mobile: Bloc, GetX, Provider, MobX, raw Navigator.push for normal navigation, raw http package instead of Dio, manual JSON parsing in widgets, hardcoded strings.

## **8.2 Localisation - ARB Files**

Localisation uses the official Flutter SDK stack with ARB files and code generation. This is the locked approach. In-memory map approaches discussed earlier in the project were superseded by this decision.

| **File**   | **Location**        | **Purpose**                        |
| ---------- | ------------------- | ---------------------------------- |
| app_en.arb | lib/l10n/app_en.arb | English translations               |
| app_ur.arb | lib/l10n/app_ur.arb | Urdu translations                  |
| l10n.yaml  | project root        | Flutter localisation configuration |

Usage in widgets:

Text(context.l10n.addToCart)

Text(context.l10n.orderStatusPaid)

⚠ Zero hardcoded strings in any widget. Every user-facing string - buttons, labels, errors, empty states, validation messages, status badges, navigation labels - must use context.l10n. Both ARB files must be updated simultaneously. Never add English-only or Urdu-only keys.

## **8.3 Supported Languages**

| **Locale** | **Code** | **Direction** | **Status**                                                          |
| ---------- | -------- | ------------- | ------------------------------------------------------------------- |
| English    | en       | LTR           | Supported in MVP                                                    |
| Urdu       | ur       | RTL           | Supported in MVP                                                    |
| Punjabi    | pa       | RTL           | Future - ARB structure supports adding without architecture changes |
| Sindhi     | sd       | RTL           | Future - ARB structure supports adding without architecture changes |

## **8.4 Navigation Structure**

| **Role**    | **Bottom nav items**                             | **Notes**                                                       |
| ----------- | ------------------------------------------------ | --------------------------------------------------------------- |
| Farmer      | Home \| Marketplace \| Scan \| Price \| Orders   | Scan opens QR scanner for traceability and product verification |
| Buyer       | Home \| Marketplace \| Cart \| Orders \| Profile | Cart shows farmer-grouped items                                 |
| Transporter | Home \| Shipments \| Scan \| History \| Profile  | Scan for delivery confirmation QR                               |

## **8.5 Implementation Order**

Agents must follow this order - do not start AI, blockchain, or payment screens before the core marketplace flow is stable:

- Project foundation - folder structure, theme, routing shell
- Localisation setup - ARB files, language toggle, locale state via Riverpod
- Core network layer - Dio client, interceptors, error handling
- Auth - models, login, register, password reset screens
- User and profile models - all 5 profile types
- Product and marketplace models
- Mock repositories for marketplace
- Marketplace home screen and product detail screen
- Cart - farmer-grouped, one-order-one-farmer enforced
- Order creation flow
- Payments - JazzCash and Stripe
- Shipments and delivery tracking
- Notifications
- Loan applications
- Community posts and comments
- AI predictions - price advisor and quality assessment screens
- Blockchain traceability screens - QR scanner and journey timeline

# **9\. Backend - farm2fork-backend**

## **9.1 Tech Stack - Locked**

| **Technology**                      | **Purpose**                                  |
| ----------------------------------- | -------------------------------------------- |
| Nest.js (Node.js 20)                | Main backend framework - modular monolith    |
| TypeScript                          | Strict typing throughout                     |
| MongoDB 7 + Mongoose                | Primary database                             |
| Redis 7                             | Caching - marketplace listings, session data |
| JWT + Passport.js                   | Authentication                               |
| bcrypt                              | Password hashing                             |
| Firebase Admin SDK                  | FCM push notification delivery               |
| Hyperledger Fabric Node.js SDK      | Blockchain transaction submission            |
| Axios or fetch                      | Internal HTTP calls to FastAPI AI service    |
| class-validator + class-transformer | DTO validation                               |
| Docker + Docker Compose             | Containerisation                             |

## **9.2 Module Boundaries**

Each Nest.js module is self-contained. Modules import each other's services only when there is a clear dependency. The dependency direction is:

- OrderModule depends on MarketplaceModule (to validate products and prices)
- PaymentModule depends on OrderModule (to update order status) and BlockchainModule (to record payment)
- BlockchainModule depends on nothing - it is a pure service module
- NotificationModule depends on all modules that trigger notifications
- AIModule depends on nothing - it calls FastAPI and saves to ai_predictions

## **9.3 Authentication and Guards**

All endpoints except /auth/login and /auth/register require a valid JWT. Role guards are applied at the controller level. Known role combinations:

| **Endpoint group**          | **Allowed roles**                       |
| --------------------------- | --------------------------------------- |
| POST /products              | farmer                                  |
| GET /products               | farmer \| buyer \| transporter \| admin |
| POST /orders                | buyer                                   |
| GET /orders (own)           | farmer \| buyer \| transporter          |
| GET /orders (all)           | admin                                   |
| POST /loans                 | farmer                                  |
| PATCH /loans/:id/review     | financial_partner \| admin              |
| PATCH /shipments/:id/status | transporter                             |
| GET /admin/\*               | admin                                   |
| GET /audit-logs             | admin                                   |
| PATCH /system-config        | admin                                   |

# **10\. AI Service - farm2fork-ai**

## **10.1 Tech Stack - Locked**

| **Technology**         | **Purpose**        |
| ---------------------- | ------------------ |
| Python 3.11            | Language           |
| FastAPI                | REST API framework |
| scikit-learn / PyTorch | ML models          |
| pandas + numpy         | Data processing    |
| uvicorn                | ASGI server        |
| Docker                 | Container          |

## **10.2 Endpoints**

| **Endpoint**          | **Method** | **Input**                                                   | **Output**                                                              |
| --------------------- | ---------- | ----------------------------------------------------------- | ----------------------------------------------------------------------- |
| POST /predict/price   | POST       | { productName, category, quantity, unit, location, season } | { predictedMinPrice, predictedMaxPrice, confidenceScore, modelVersion } |
| POST /predict/quality | POST       | { productName, category, images\[\] (optional) }            | { qualityGrade (A\|B\|C), confidenceScore, modelVersion }               |
| GET /health           | GET        | None                                                        | { status: 'ok' }                                                        |

## **10.3 Model Strategy**

Due to limited availability of Pakistani agricultural commodity price data, the following fallback strategy is used:

- Attempt to train on publicly available datasets (Pakistan Bureau of Statistics, AMIS commodity data)
- If insufficient data, implement a rule-based pricing fallback that uses category averages and seasonal adjustment factors
- Store all predictions in ai_predictions collection regardless of whether ML model or rule-based fallback was used - modelVersion field distinguishes them
- Confidence score is lower for rule-based predictions (0.5 or below) vs ML predictions

⚠ Dataset collection must begin in Sprint 1 in parallel with other work. Do not wait until Sprint 5 to start gathering training data.

# **11\. Blockchain - farm2fork-blockchain**

## **11.1 Tech Stack - Locked**

| **Technology**         | **Purpose**                                             |
| ---------------------- | ------------------------------------------------------- |
| Hyperledger Fabric 2.5 | Permissioned blockchain framework                       |
| Go                     | Chaincode (smart contract) language                     |
| Docker                 | Peer node, orderer node containers                      |
| Fabric Node.js SDK     | Used by Nest.js BlockchainModule to submit transactions |

## **11.2 Chaincode Events**

The Fabric chaincode handles two transaction types:

| **Transaction type**   | **Triggered by**                                                                  | **Payload stored**                                                      |
| ---------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| RecordPayment          | PaymentService after payment success                                              | orderId, buyerId, farmerId, amount, currency, gateway, paidAt           |
| RecordSupplyChainEvent | MarketplaceService on product listing; TransportService on shipment status change | productId, farmerId, eventType, location, actorId, actorRole, timestamp |

## **11.3 Local Development Setup**

Hyperledger Fabric runs locally via Docker Compose using the Fabric test network scripts. The blockchain container in the workspace Docker Compose file starts the peer and orderer nodes. Chaincode is deployed to the test channel during startup.

⚠ Fabric setup is the highest-risk technical task in the project (Risk TR-01). Allocate the first 2 weeks of Sprint 4 specifically for Fabric setup and smoke testing. A mock ledger fallback must be ready in case Fabric setup is unstable during development.

# **12\. Admin Web Panel - farm2fork-web**

## **12.1 Tech Stack - Locked**

| **Technology**       | **Purpose**                     |
| -------------------- | ------------------------------- |
| Next.js (App Router) | React framework for admin panel |
| TypeScript           |                                 |
| Tailwind CSS         | Styling                         |
| React Query or SWR   | Data fetching and caching       |
| Axios                | HTTP client                     |

## **12.2 Admin Panel Screens**

| **Screen**        | **Route**   | **Purpose**                                         |
| ----------------- | ----------- | --------------------------------------------------- |
| Dashboard         | /dashboard  | Stats overview, recent activity, weekly order chart |
| User Management   | /users      | Search, filter, view, deactivate user accounts      |
| Products          | /products   | View and moderate product listings                  |
| Orders            | /orders     | View all orders, filter by status                   |
| Loan Applications | /loans      | Review, approve, reject loan applications           |
| Audit Logs        | /audit-logs | Filter and inspect platform activity logs           |
| System Config     | /config     | Update platform_fee_percent and other config keys   |

The admin panel does not need full Urdu localisation for MVP - it is used by administrators who are expected to be English literate. Basic Urdu support may be added post-MVP.

# **13\. Sprint Plan**

8 sprints of 2 weeks each. 93 total story points across 17 user stories. This sprint plan covers the requirements and core development phase. The 42-week Gantt chart in the Phase 1 SRS document covers the full project timeline including infrastructure, testing, and deployment.

| **Sprint** | **Duration** | **Goal**                                                     | **User Stories**    | **Points** |
| ---------- | ------------ | ------------------------------------------------------------ | ------------------- | ---------- |
| Sprint 1   | 2 weeks      | User registration, login, password reset                     | US-01, US-02, US-03 | 9          |
| Sprint 2   | 2 weeks      | Farmer product listings and marketplace browsing             | US-04, US-05        | 10         |
| Sprint 3   | 2 weeks      | Order placement and payment processing                       | US-06, US-07        | 16         |
| Sprint 4   | 2 weeks      | QR traceability and blockchain recording                     | US-08, US-11        | 16         |
| Sprint 5   | 2 weeks      | AI price suggestions and loan application                    | US-09, US-10        | 13         |
| Sprint 6   | 2 weeks      | Transport module - shipment management and delivery tracking | US-16, US-17        | 13         |
| Sprint 7   | 2 weeks      | Admin user management and audit logs                         | US-12, US-15        | 10         |
| Sprint 8   | 2 weeks      | Community module - posts and comments                        | US-13, US-14        | 6          |
|            |              | **Total**                                                    |                     | **93**     |

# **14\. Key Risks for Agents to Know**

| **Risk ID** | **Risk**                                                                           | **Priority** | **Mitigation**                                                                                                           |
| ----------- | ---------------------------------------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------ |
| TR-01       | Hyperledger Fabric setup unstable during development                               | High         | Allocate Sprint 4 week 1-2 for Fabric setup. Maintain mock ledger fallback for frontend integration.                     |
| TR-02       | AI training data insufficient for Pakistani agricultural markets                   | Critical     | Start dataset collection in Sprint 1. Use rule-based pricing fallback if ML data is inadequate.                          |
| TR-03       | Payment gateway integration delayed or rate-limited                                | High         | Test JazzCash and Stripe in Sprint 3. Use abstraction layer so gateway can be swapped.                                   |
| TM-01       | Uneven workload - Junaid responsible for Blockchain + AI + lead dev                | Critical     | Abdullah owns backend integration and documentation. Qaim owns all UI/UX independently. Strict sprint task distribution. |
| PR-03       | Evaluator flags project as insufficiently differentiated from Agriconnect/Farmease | Medium       | Blockchain, AI, microfinance, and transport must all be demonstrable at Phase 2 evaluation.                              |

# **15\. Universal Rules for All Agents**

These rules apply to every agent in every repo. Repo-specific rulesets add to these, never replace them.

## **15.1 Schema Rules**

- Never rename a database field without explicit approval from the project owner
- Never add a new collection without explicit approval
- Never change a field's type, enum values, or required status without approval
- Use the exact role values: farmer | buyer | transporter | financial_partner | admin
- Use initialBlockchainRecordId on products - not blockchainTxId (retired name)

## **15.2 Architecture Rules**

- Do not propose splitting Nest.js into microservices
- Do not add services that communicate over HTTP inside the same Docker network when in-process calls are possible
- Do not add new Docker containers without justification and approval
- AI service is called by Nest.js only - not by the mobile app directly

## **15.3 Security Rules**

- Never log passwordHash, fcmToken, CNIC, bank account details, gatewayRef, or document URLs
- Never expose raw audit log metadata to non-admin clients
- Never expose raw blockchain payload to buyer or farmer clients
- Never store sensitive data in plain text local storage on the mobile app

## **15.4 Business Logic Rules**

- One-Order-One-Farmer: enforce at OrderService, enforce at mobile cart, never create a mixed-farmer order
- Platform fee is percentage-based: read from ConfigService, snapshot on order, never recalculate retroactively
- Loans are for farmers only: role guard at LoanService, reject financial_partner, buyer, transporter, admin applicants
- Blockchain recording is async: never block the primary API response waiting for Fabric confirmation

## **15.5 What to Do When Uncertain**

- If a decision is not covered by this document or the repo ruleset, stop and ask the project owner - do not make architectural decisions unilaterally
- If this document conflicts with a repo ruleset, the repo ruleset is more specific - but flag the conflict to the project owner
- If you encounter an existing pattern in the codebase that violates this document, flag it rather than silently working around it

## **15.6 Forbidden Agent Behaviours - All Repos**

⚠ Agents must never do any of the following:

- Silently rename schema fields
- Add state management packages to the mobile app beyond Riverpod
- Create mixed-farmer orders
- Hardcode user-facing strings in the mobile app
- Expose sensitive fields in API responses
- Log sensitive data
- Parse JSON inside widgets
- Start AI or blockchain screens before the core marketplace flow is stable
- Directly access system_config collection from any client - always go through ConfigService
- Store blockchain payloads as raw untyped objects - always use the typed sub-document structure

# **16\. Standard Agent Prompt Template**

Use this template when assigning work to any agent on any repo:

You are working on the Farm2Fork project.

Before writing any code, read:

1\. Farm2Fork Project Master Context Document (this file)

2\. The repo-specific ruleset for \[REPO NAME\]

Task: \[describe task clearly\]

Constraints:

\- Do not rename schema fields

\- Do not create mixed-farmer orders

\- Do not hardcode user-facing strings

\- Do not expose sensitive fields

\- \[add task-specific constraints\]

Expected output:

\- Files created or changed

\- What was implemented

\- Schema fields used (confirm alignment with master context)

\- Assumptions made

\- Remaining issues or blockers

# **17\. Quick Reference**

## **17.1 All 17 Collections at a Glance**

| **#** | **Collection**             | **Key relationships**                                                     | **Sensitive fields**       |
| ----- | -------------------------- | ------------------------------------------------------------------------- | -------------------------- |
| 1     | users                      | Root entity - all profiles ref this                                       | passwordHash, fcmToken     |
| 2     | farmer_profiles            | userId → users                                                            | cnic, bankAccountDetails   |
| 3     | buyer_profiles             | userId → users                                                            | cnic                       |
| 4     | transporter_profiles       | userId → users                                                            | cnic, licenseNumber        |
| 5     | financial_partner_profiles | userId → users                                                            | cnic, licenseNumber        |
| 6     | products                   | farmerId → users                                                          | none                       |
| 7     | orders                     | buyerId → users, farmerId → users, paymentId, shipmentId                  | none (but snapshot prices) |
| 8     | payments                   | orderId → orders, buyerId → users                                         | gatewayRef                 |
| 9     | blockchain_transactions    | referenceId polymorphic                                                   | payload internals          |
| 10    | shipments                  | orderId → orders, transporterId → users                                   | none                       |
| 11    | loan_applications          | applicantId → users (farmer only), reviewedBy → users (financial_partner) | documents URLs             |
| 12    | audit_logs                 | actorId → users, targetId polymorphic                                     | metadata.before/after      |
| 13    | posts                      | authorId → users                                                          | none                       |
| 14    | comments                   | postId → posts, authorId → users                                          | none                       |
| 15    | notifications              | userId → users, relatedEntityId polymorphic                               | none                       |
| 16    | ai_predictions             | userId → users, productId → products                                      | none                       |
| 17    | system_config              | updatedBy → users (admin only)                                            | none                       |

## **17.2 User Roles - Exact Values**

| **Role value**    | **Profile collection**     | **Can do**                                                           |
| ----------------- | -------------------------- | -------------------------------------------------------------------- |
| farmer            | farmer_profiles            | Create products, apply for loans, use AI pricing, receive payments   |
| buyer             | buyer_profiles             | Browse marketplace, place orders, pay, track delivery, scan QR       |
| transporter       | transporter_profiles       | Accept and manage shipments, update delivery status                  |
| financial_partner | financial_partner_profiles | Review and approve/reject loan applications                          |
| admin             | none (no separate profile) | Manage users, view audit logs, update system config, review all data |

## **17.3 Order Status Flow**

pending → paid → processing → shipped → delivered (or cancelled at any point before delivered)

## **17.4 Payment Status Flow**

pending → success (triggers blockchain recording) → refunded (if applicable)

pending → failed (triggers retry or manual resolution)

## **17.5 Shipment Status Flow**

assigned → picked_up → in_transit → delivered (or failed at any point)

Every status change appends a record to statusHistory\[\] with { status, timestamp, note, updatedBy }.

## **17.6 Loan Application Status Flow**

pending → under_review → approved → repaid

pending → under_review → rejected
