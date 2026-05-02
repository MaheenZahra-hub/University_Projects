#include <iostream>
using namespace std;

// Function prototypes
void displayQuestion(const char questions[][200], const char answers[], int index, const string& era, string& currentEra, int& score);
void askQuestion(const char questions[][200], const char answers[], string& currentEra, int& score, const string& era, int& totalQuestionsAsked);

int main() {
    // Questions and answers for each era
    const char presentQuestions[10][200] = {
        "1. Present Era: What is the current year?\nA) 2020\nB) 2023\nC) 2024\nD) 2025",
        "2. Present Era: Who is the most-followed person on Instagram in 2024?\nA) Ronaldo\nB) Kylie jenner\nC) Messi\nD) Selena gomez",
        "3. Present Era: Who is most polluted city in Pakistan in 2024?\nA) Quetta\nB) Lahore\nC) Peshawar\nD) Karachi",
        "4. Present Era: What is the name of the latest smartphone model by Apple?\nA) I phone 12\nB) I phone 16\nC) Iphone 15\nD) Iphone 13",
        "5. Present Era: Which is the largest city in Pakistan by population in 2024?\nA) Lahore\nB) Islamabad\nC) Karachi\nD) Multan",
        "6. Present Era: Which is the most popular streaming platform currently?\nA) Netflix\nB) Amazon prime\nC) Disney hotstar \nD) Alt balaji",
        "7. Present Era:Who is the most influential TikTok star of 2024?\nA) Charlie D Amalio\nB) Zack king\nC) Rosie\nD) Lisa",
        "8. Present Era: Which TV show broke streaming records in pakistan 2024?\nA) Iqtadar\nB) Jaan e sar\nC) Kabhi main Kbhi tum\nD) Ishq murshid",
        "9. Present Era:What are the latest trends in wearable health devices?\nA) All Of these\nB) Smart Rings\nC) Smart watch\nD) LED",
        "10. Present Era: Who is the current Prime Minister of Pakistan?\nA) Imran Khan\nB) Shahbaz Sharif\nC) Nawaz Sharif\nD) Anwar-ul-Haq Kakar"
    };
    const char presentAnswers[10] = { 'C', 'A', 'B', 'B', 'C', 'A', 'A', 'C', 'B', 'D' };

    const char pastQuestions[10][200] = {
        "1. Past Era: Who was the founder of Pakistan?\nA) Allama Iqbal\nB) Liaquat Ali Khan\nC) Muhammad Ali Jinnah\nD) Sir Syed Ahmed Khan",
        "2. Past Era: Which was the first capital of Pakistan after independence?\nA) Karachi\nB) Lahore\nC) Islamabad\nD) Rawalpindi",
        "3. Past Era: Who was the first President of Pakistan?\nA) Iskander Mirza\nB) Ayub Khan\nC) Liaquat Ali Khan\nD) Muhammad Ali Jinnah",
        "4. Past Era: Who was the first Caliph of Islam?\nA) Abu Bakr (RA)\nB) Umar (RA)\nC) Uthman (RA)\nD) Ali (RA)",
        "5. Past Era: What year did the Battle of Badr take place?\nA) 622 CE\nB) 624 CE\nC) 632 CE\nD) 650 CE",
        "6. Past Era: Where did the Prophet Muhammad (PBUH) migrate in 622 CE, marking the beginning of the Islamic calendar?\nA) Mecca\nB) Medina\nC) Taif\nD) Jerusalem",
        "7. Past Era: Who was the first woman to accept Islam?\nA) Khadija (RA)\nB) Aisha (RA)\nC) Fatima (RA)\nD) Hafsa (RA)",
        "8. Past Era: Who built the Taj Mahal?\nA) Akbar\nB) Jahangir\nC) Shah Jahan\nD) Aurangzeb",
        "9. Past Era: In which year did the War of Independence happen between Hindus, Muslims, and the British?\nA) 1757\nB) 1857\nC) 1901\nD) 1947",
        "10. Past Era: In which year did Muhammad Ali Jinnah die?\nA) 1946\nB) 1947\nC) 1948\nD) 1949"
    };
    const char pastAnswers[10] = { 'C', 'A', 'A', 'A', 'B', 'B', 'A', 'C', 'B', 'C' };

    const char futureQuestions[10][200] = {
        "1. Future Era: When is NASA planning to send humans to Mars?\nA) 2034\nB) 2037\nC) 2056\nD) 2035",
        "2. Future Era: What kind of games will people play in 2050?\nA) VR-based games\nB) AR-based games\nC) Mind-controlled games\nD) All of the above",
        "3. Future Era: In the future, how might we travel to other countries?\nA) Flying cars\nB) Spacecraft\nC) Hyperloops\nD) Teleportation",
        "4. Future Era: What will be the coolest job in the future?\nA) AI Developer\nB) Space Pilot\nC) Genetic Designer\nD) All of the above",
        "5. Future Era: What sport might be the most popular in 2050?\nA) Robot Soccer\nB) Drone Racing\nC) Holographic Cricket\nD) E-sports",
        "6. Future Era: What is expected to become the norm in urban transportation by 2040?\nA) Electric bikes only\nB) Flying cars\nC)  Hovercrafts\nD) Self-drving cars",
        "7. Future Era: What new feature might future smartphones have?\nA) Holographic displays\nB) Brain-to-phone interfaces\nC) Solar-powered charging\nD) All of the above",
        "8. Future Era: What percentage of global energy production is expected to come from renewable sources by 2050?\nA) 100%\nB) 20%\nC) 50% \nD) 80%",
        "9. Future Era: How might kids do their homework in the future?\nA) AI tutors\nB) Virtual classrooms\nC) Brain-enhancing devices\nD) All of the above",
        "10. Future Era: What kind of pets might we have in the future?\nA) Robotic pets\nB) Genetically engineered animals\nC) AI companions\nD) All of the above"
    };
    const char futureAnswers[10] = { 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D' };

    string currentEra = "Present";
    int score = 0, totalQuestionsAsked = 0;

    cout << "Welcome to the Time Travel Quiz Game!\n";
    cout << "Rules: Answer correctly to move forward, incorrectly to move backward.\n";
    cout << "Answer 10 unique questions to complete the game.\n\n";

    while (totalQuestionsAsked < 10) {
        if (currentEra == "Present") {
            askQuestion(presentQuestions, presentAnswers, currentEra, score, "Present", totalQuestionsAsked);
        }
        else if (currentEra == "Past") {
            askQuestion(pastQuestions, pastAnswers, currentEra, score, "Past", totalQuestionsAsked);
        }
        else if (currentEra == "Future") {
            askQuestion(futureQuestions, futureAnswers, currentEra, score, "Future", totalQuestionsAsked);
        }
    }

    cout << "\nGame Over! You answered " << score << "/10 questions correctly.\n";
    cout << "Thank you for playing!\n";
    return 0;
}

void displayQuestion(const char questions[][200], const char answers[], int index, const string& era, string& currentEra, int& score) {
    char userAnswer;
    cout << era << ": " << questions[index] << "\nYour answer: ";
    cin >> userAnswer;
    if (toupper(userAnswer) == answers[index]) {
        cout << "Correct!\n";
        score++;
        if (era == "Present") {
            cout << "Now move forward to future era.\n\n";
            currentEra = "Future";
        }
        else if (era == "Past") {
            cout << "Now move forward to present era.\n\n";
            currentEra = "Present";
        }
    }
    else {
        cout << "Incorrect.\n";
        if (era == "Future") {
            cout << "Now move backward to present era.\n\n";
            currentEra = "Present";
        }
        else if (era == "Present") {
            cout << "Now move backward to past era.\n\n";
            currentEra = "Past";
        }
    }
}

void askQuestion(const char questions[][200], const char answers[], string& currentEra, int& score, const string& era, int& totalQuestionsAsked) {
    int questionIndex = totalQuestionsAsked % 10;
    displayQuestion(questions, answers, questionIndex, era, currentEra, score);
    totalQuestionsAsked++; // Increment total questions asked
}
