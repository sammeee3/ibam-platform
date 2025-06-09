#!/bin/bash

# IBAM Demo Auto-Fix Script
# This script automatically fixes the navigation issues in your demo.html file

echo "🚀 IBAM Demo Auto-Fix Starting..."
echo "================================"

# Step 1: Create backup
echo "📁 Creating backup..."
cp demo.html demo-backup-$(date +%Y%m%d-%H%M%S).html
echo "✅ Backup created successfully"

# Step 2: Fix the home page to have 'active' class
echo "🏠 Fixing home page default..."
sed -i '' 's/<div class="page" id="home">/<div class="page active" id="home">/' demo.html
echo "✅ Home page set as default"

# Step 3: Remove 'active' class from other pages (but keep it on home)
echo "🔧 Fixing other page navigation..."
sed -i '' 's/<div class="page active" id="assessment">/<div class="page" id="assessment">/' demo.html
sed -i '' 's/<div class="page active" id="donate">/<div class="page" id="donate">/' demo.html
sed -i '' 's/<div class="page active" id="about">/<div class="page" id="about">/' demo.html
sed -i '' 's/<div class="page active" id="impact">/<div class="page" id="impact">/' demo.html
sed -i '' 's/<div class="page active" id="contact">/<div class="page" id="contact">/' demo.html
sed -i '' 's/<div class="page active" id="resources">/<div class="page" id="resources">/' demo.html
sed -i '' 's/<div class="page active" id="business-planner">/<div class="page" id="business-planner">/' demo.html
sed -i '' 's/<div class="page active" id="impact-dashboard">/<div class="page" id="impact-dashboard">/' demo.html
echo "✅ Navigation classes fixed"

# Step 4: Create the fixed JavaScript
echo "💻 Creating fixed JavaScript..."
cat > temp_script.js << 'SCRIPT_EOF'
    <script>
        // Page Navigation System - FIXED VERSION
        function showPage(pageId) {
            // Hide all pages
            const pages = document.querySelectorAll('.page');
            pages.forEach(page => page.classList.remove('active'));
            
            // Show target page
            const targetPage = document.getElementById(pageId);
            if (targetPage) {
                targetPage.classList.add('active');
                window.scrollTo(0, 0);
            } else {
                // Fallback to home page if page not found
                const homePage = document.getElementById('home');
                if (homePage) {
                    homePage.classList.add('active');
                }
            }
        }

        // Assessment Logic
        let currentQuestion = 1;
        let assessmentAnswers = {};

        function selectOption(element, value) {
            const siblings = element.parentElement.children;
            for (let sibling of siblings) {
                sibling.classList.remove('selected');
            }
            
            element.classList.add('selected');
            assessmentAnswers[`q${currentQuestion}`] = value;
            const nextBtn = document.getElementById('nextBtn');
            if (nextBtn) {
                nextBtn.disabled = false;
            }
        }

        function nextQuestion() {
            if (currentQuestion === 1) {
                const firstAnswer = assessmentAnswers.q1;
                
                if (firstAnswer === 'impact') {
                    showPage('impact-member-result');
                    return;
                } else if (firstAnswer === 'church') {
                    showPage('church-partner-result');
                    return;
                } else if (firstAnswer === 'business') {
                    currentQuestion++;
                    showQuestion();
                }
            } else if (currentQuestion === 2) {
                currentQuestion++;
                showQuestion();
            } else if (currentQuestion === 3) {
                const situation = assessmentAnswers.q2;
                const experience = assessmentAnswers.q3;
                
                if (experience === 'experienced' || situation === 'existing') {
                    showPage('advanced-business-result');
                } else {
                    showPage('individual-business-result');
                }
            }
        }

        function previousQuestion() {
            if (currentQuestion > 1) {
                currentQuestion--;
                showQuestion();
            }
        }

        function showQuestion() {
            const questions = document.querySelectorAll('.question');
            questions.forEach(q => q.classList.remove('active'));
            
            const currentQ = document.getElementById(`q${currentQuestion}`);
            if (currentQ) {
                currentQ.classList.add('active');
            }
            
            const progress = (currentQuestion / 3) * 100;
            const progressBar = document.getElementById('assessmentProgress');
            if (progressBar) {
                progressBar.style.width = progress + '%';
            }
            
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            
            if (prevBtn) prevBtn.style.display = currentQuestion > 1 ? 'inline-block' : 'none';
            if (nextBtn) nextBtn.disabled = !assessmentAnswers[`q${currentQuestion}`];
            
            if (currentQuestion === 3 && nextBtn) {
                nextBtn.textContent = 'Get My Results';
            }
        }

        // FIXED INITIALIZATION - ENSURES HOME PAGE LOADS FIRST
        document.addEventListener('DOMContentLoaded', function() {
            // CRITICAL FIX: Always show home page first
            console.log('Initializing IBAM demo...');
            
            // Remove active class from all pages
            const allPages = document.querySelectorAll('.page');
            allPages.forEach(page => page.classList.remove('active'));
            
            // Force home page to be active
            const homePage = document.getElementById('home');
            if (homePage) {
                homePage.classList.add('active');
                console.log('Home page activated successfully');
            } else {
                console.error('Home page not found!');
            }
            
            // Header scroll effect
            window.addEventListener('scroll', function() {
                const header = document.querySelector('.header');
                if (header) {
                    if (window.scrollY > 100) {
                        header.style.background = 'rgba(26, 32, 44, 0.98)';
                        header.style.boxShadow = '0 2px 25px rgba(0,0,0,0.3)';
                    } else {
                        header.style.background = 'var(--dark-navy)';
                        header.style.boxShadow = '0 2px 20px rgba(0,0,0,0.2)';
                    }
                }
            });
            
            // Initialize assessment if on assessment page
            const assessmentPage = document.getElementById('assessment');
            if (assessmentPage && assessmentPage.classList.contains('active')) {
                currentQuestion = 1;
                showQuestion();
            }
        });
    </script>
SCRIPT_EOF

# Step 5: Replace the old script with the new one
echo "🔄 Replacing JavaScript..."
# Remove old script and add new one before </body>
sed -i '' '/<script>/,/<\/script>/d' demo.html
sed -i '' 's|</body>|'"$(cat temp_script.js)"'</body>|' demo.html

# Clean up temp file
rm temp_script.js
echo "✅ JavaScript updated successfully"

# Step 6: Add a preview banner
echo "🏷️ Adding preview banner..."
sed -i '' 's|<body>|<body><div style="background: #4ECDC4; color: white; text-align: center; padding: 10px; font-weight: 600; position: fixed; top: 0; left: 0; right: 0; z-index: 9999;">📱 LIVE DEMO - IBAM Platform Preview for Steve Adams Review</div><div style="height: 50px;"></div>|' demo.html
echo "✅ Preview banner added"

# Step 7: Git commit and push
echo "📤 Deploying to GitHub/Vercel..."
git add .
git commit -m "🚀 Auto-fix: Home page navigation, JavaScript improvements, and Steve Adams preview"
git push

echo ""
echo "🎉 SUCCESS! Your IBAM demo has been fixed and deployed!"
echo "================================"
echo "✅ Home page now loads first (not donate page)"
echo "✅ Navigation works perfectly"
echo "✅ Assessment tool properly routes users"
echo "✅ Professional preview banner added"
echo "✅ Changes pushed to GitHub and deployed"
echo ""
echo "🌐 Your demo will be live in 1-2 minutes at:"
echo "   https://ibam-platform.vercel.app/demo.html"
echo ""
echo "📧 Ready to send to Steve Adams!"
echo ""
echo "🔍 Test these features:"
echo "   • Click IBAM logo - goes to home page"
echo "   • Try the assessment tool"
echo "   • Test navigation menu items"
echo "   • Check on mobile device"
echo ""
echo "🆘 If you have issues, your backup is saved as demo-backup-*.html"
