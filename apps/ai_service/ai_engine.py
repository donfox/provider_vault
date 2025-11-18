"""
AI Engine for Provider Vault

Core AI functions using OpenAI API for provider-related intelligence.
Focus: Learning AI engineering and prompt engineering fundamentals.
"""

import os
from openai import OpenAI
from dotenv import load_dotenv
import db_client

# Load environment variables
load_dotenv()

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
MODEL = os.getenv('OPENAI_MODEL', 'gpt-4o-mini')


def generate_specialty_description(specialty):
    """
    Generate a patient-friendly description of a medical specialty.
    
    This is your first AI function! It demonstrates:
    - Basic OpenAI API usage
    - Prompt engineering for clear, helpful responses
    - Practical application of AI for healthcare context
    
    Args:
        specialty (str): Medical specialty name (e.g., "Cardiology")
        
    Returns:
        str: Patient-friendly description of the specialty
    """
    
    prompt = f"""You are a helpful medical information assistant. 

Generate a clear, patient-friendly description of the medical specialty: {specialty}

Requirements:
- Write in simple, accessible language (8th grade reading level)
- 2-3 paragraphs maximum
- Explain what this type of doctor does
- Mention common conditions they treat
- Help patients understand when they might need this specialist
- Use a warm, reassuring tone

Do not include:
- Medical jargon without explanation
- Technical details about training/certification
- Promotional language"""

    try:
        response = client.chat.completions.create(
            model=MODEL,
            messages=[
                {"role": "system", "content": "You are a helpful medical information assistant who explains healthcare topics in patient-friendly language."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,  # Balanced creativity and consistency
            max_tokens=300
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        return f"Error generating description: {str(e)}"


def suggest_related_specialties(specialty, count=3):
    """
    Suggest related medical specialties for referral purposes.
    
    This demonstrates:
    - Structured output from AI
    - Medical knowledge application
    - Practical clinical workflow support
    
    Args:
        specialty (str): Medical specialty name
        count (int): Number of related specialties to suggest (default: 3)
        
    Returns:
        list[dict]: List of related specialties with reasons
            Format: [{"specialty": "...", "reason": "..."}, ...]
    """
    
    prompt = f"""You are a medical referral coordinator.

For the specialty "{specialty}", suggest {count} related medical specialties that commonly work together or receive referrals.

For each specialty, provide:
1. The specialty name
2. A brief reason why they often collaborate

Format your response as a simple list:
1. [Specialty Name]: [One sentence reason]
2. [Specialty Name]: [One sentence reason]
etc.

Focus on practical, common referral patterns in healthcare."""

    try:
        response = client.chat.completions.create(
            model=MODEL,
            messages=[
                {"role": "system", "content": "You are a medical referral coordinator with deep knowledge of healthcare specialties."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.5,  # Lower temperature for more consistent results
            max_tokens=250
        )
        
        # Parse the response into structured data
        content = response.choices[0].message.content.strip()
        suggestions = []
        
        for line in content.split('\n'):
            line = line.strip()
            if line and (line[0].isdigit() or line.startswith('-')):
                # Remove numbering/bullets
                clean_line = line.lstrip('0123456789.-) ')
                if ':' in clean_line:
                    specialty_name, reason = clean_line.split(':', 1)
                    suggestions.append({
                        'specialty': specialty_name.strip(),
                        'reason': reason.strip()
                    })
        
        return suggestions[:count]  # Ensure we return exactly count items
        
    except Exception as e:
        return [{"specialty": "Error", "reason": str(e)}]


def analyze_provider_distribution(providers):
    """
    Analyze patterns in a list of providers and generate insights.
    
    This demonstrates:
    - AI analysis of structured data
    - Pattern recognition
    - Generating actionable insights
    
    Args:
        providers (list[dict]): List of provider records from database
        
    Returns:
        str: Analysis summary with insights
    """
    
    if not providers:
        return "No providers to analyze."
    
    # Prepare summary statistics
    total_count = len(providers)
    
    # Count by specialty
    specialty_counts = {}
    for p in providers:
        specialty = p.get('specialty', 'Unknown')
        specialty_counts[specialty] = specialty_counts.get(specialty, 0) + 1
    
    # Count by state
    state_counts = {}
    for p in providers:
        state = p.get('state', 'Unknown')
        state_counts[state] = state_counts.get(state, 0) + 1
    
    # Build context for AI
    context = f"""Provider Dataset Analysis:

Total Providers: {total_count}

Specialty Distribution:
{chr(10).join([f"  - {spec}: {count}" for spec, count in sorted(specialty_counts.items(), key=lambda x: x[1], reverse=True)])}

Geographic Distribution (by state):
{chr(10).join([f"  - {state}: {count}" for state, count in sorted(state_counts.items(), key=lambda x: x[1], reverse=True)])}"""

    prompt = f"""You are a healthcare network analyst.

Based on this provider data, generate a brief analysis (2-3 paragraphs) that includes:
1. Key patterns you observe
2. Potential gaps in coverage
3. One actionable recommendation

{context}

Focus on practical insights that would help a healthcare administrator."""

    try:
        response = client.chat.completions.create(
            model=MODEL,
            messages=[
                {"role": "system", "content": "You are a healthcare network analyst who identifies patterns and provides actionable insights."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.6,
            max_tokens=350
        )
        
        return response.choices[0].message.content.strip()
        
    except Exception as e:
        return f"Error analyzing providers: {str(e)}"


def recommend_provider_by_symptoms(symptoms, location_state=None):
    """
    Recommend appropriate medical specialty based on patient symptoms.
    
    This demonstrates:
    - Medical reasoning with AI
    - Safety-conscious prompt engineering
    - Structured output with urgency assessment
    - Integration with real provider availability
    
    Args:
        symptoms (str): Patient-described symptoms (e.g., "chest pain, shortness of breath")
        location_state (str, optional): Two-letter state code to check provider availability
        
    Returns:
        dict: {
            'recommended_specialties': [list of specialty names],
            'reasoning': str,
            'urgency_level': 'low' | 'medium' | 'high' | 'emergency',
            'disclaimer': str,
            'available_providers': [list of provider dicts] (if location_state provided)
        }
    """
    
    prompt = f"""You are a medical triage assistant helping patients understand which type of doctor they should see.

PATIENT SYMPTOMS: {symptoms}

Your task:
1. Identify 1-3 appropriate medical specialties for these symptoms (in priority order)
2. Explain your reasoning in 2-3 sentences
3. Assess urgency level: low, medium, high, or EMERGENCY
4. If EMERGENCY (life-threatening symptoms like severe chest pain, difficulty breathing, stroke symptoms), explicitly state "SEEK IMMEDIATE EMERGENCY CARE"

IMPORTANT SAFETY RULES:
- Never diagnose conditions - only suggest specialties
- For life-threatening symptoms, always recommend emergency care FIRST
- Be conservative - when in doubt, recommend higher urgency
- Include disclaimer that this is not medical advice

Format your response EXACTLY like this:

SPECIALTIES: [Specialty 1], [Specialty 2], [Specialty 3]
REASONING: [Your 2-3 sentence explanation]
URGENCY: [low/medium/high/EMERGENCY]
EMERGENCY_ACTION: [If EMERGENCY, state "SEEK IMMEDIATE EMERGENCY CARE" otherwise "N/A"]

Examples of specialties: Cardiology, Neurology, Orthopedics, Primary Care, Psychiatry, Dermatology, etc."""

    try:
        response = client.chat.completions.create(
            model=MODEL,
            messages=[
                {
                    "role": "system", 
                    "content": "You are a careful medical triage assistant. Patient safety is your top priority. Never diagnose - only recommend specialties. Always err on the side of caution."
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=400
        )
        
        content = response.choices[0].message.content.strip()
        
        specialties = []
        reasoning = ""
        urgency = "medium"
        emergency_action = ""
        
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('SPECIALTIES:'):
                specialty_text = line.replace('SPECIALTIES:', '').strip()
                specialties = [s.strip() for s in specialty_text.split(',')]
            elif line.startswith('REASONING:'):
                reasoning = line.replace('REASONING:', '').strip()
            elif line.startswith('URGENCY:'):
                urgency = line.replace('URGENCY:', '').strip().lower()
            elif line.startswith('EMERGENCY_ACTION:'):
                emergency_action = line.replace('EMERGENCY_ACTION:', '').strip()
        
        result = {
            'recommended_specialties': specialties,
            'reasoning': reasoning,
            'urgency_level': urgency,
            'emergency_action': emergency_action if emergency_action != "N/A" else None,
            'disclaimer': "⚠️ This is not medical advice. Always consult with a qualified healthcare provider for proper diagnosis and treatment.",
            'available_providers': []
        }
        
        if location_state and specialties:
            try:
                primary_specialty = specialties[0]
                providers = db_client.get_providers_by_state(location_state, limit=50)
                
                matching_providers = [
                    p for p in providers 
                    if p.get('specialty', '').lower() == primary_specialty.lower()
                ]
                
                result['available_providers'] = matching_providers[:5]
                result['location_checked'] = location_state
                
            except Exception as e:
                result['provider_search_error'] = str(e)
        
        return result
        
    except Exception as e:
        return {
            'error': f"Error processing symptoms: {str(e)}",
            'recommended_specialties': [],
            'reasoning': '',
            'urgency_level': 'unknown',
            'disclaimer': "⚠️ System error. Please consult a healthcare provider directly."
        }


def semantic_search_providers(query, limit=10):
    """
    Natural language search for providers.
    
    This demonstrates:
    - Intent understanding from natural language
    - Query expansion and synonym matching
    - Practical application of AI for search
    
    Args:
        query (str): Natural language query (e.g., "doctor for my elderly parent's memory issues")
        limit (int): Maximum number of results to return
        
    Returns:
        dict: {
            'understood_intent': str,
            'search_terms': [list of extracted terms],
            'recommended_specialties': [list of specialties],
            'providers': [list of matching providers]
        }
    """
    
    analysis_prompt = f"""You are a medical search assistant analyzing a patient's search query.

QUERY: "{query}"

Your task:
1. Understand what the patient is looking for
2. Extract key medical concepts, symptoms, or conditions mentioned
3. Identify 2-4 relevant medical specialties that could help
4. Consider synonyms and related terms (e.g., "memory problems" → dementia, Alzheimer's, cognitive decline)

Format your response EXACTLY like this:

INTENT: [One sentence describing what the patient needs]
KEY_TERMS: [term1], [term2], [term3]
SPECIALTIES: [Specialty1], [Specialty2], [Specialty3]

Examples:
- Query: "doctor for my knee pain from running"
  INTENT: Patient has knee pain related to running/sports activity
  KEY_TERMS: knee, pain, sports, orthopedic
  SPECIALTIES: Orthopedics, Sports Medicine, Physical Medicine

- Query: "someone to help with anxiety and stress"
  INTENT: Patient seeking mental health support for anxiety
  KEY_TERMS: anxiety, stress, mental health, therapy
  SPECIALTIES: Psychiatry, Clinical Psychology, Counseling"""

    try:
        response = client.chat.completions.create(
            model=MODEL,
            messages=[
                {
                    "role": "system",
                    "content": "You are a medical search assistant who understands patient needs and maps them to appropriate medical specialties."
                },
                {"role": "user", "content": analysis_prompt}
            ],
            temperature=0.4,
            max_tokens=250
        )
        
        content = response.choices[0].message.content.strip()
        
        intent = ""
        key_terms = []
        specialties = []
        
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('INTENT:'):
                intent = line.replace('INTENT:', '').strip()
            elif line.startswith('KEY_TERMS:'):
                terms_text = line.replace('KEY_TERMS:', '').strip()
                key_terms = [t.strip() for t in terms_text.split(',')]
            elif line.startswith('SPECIALTIES:'):
                spec_text = line.replace('SPECIALTIES:', '').strip()
                specialties = [s.strip() for s in spec_text.split(',')]
        
        all_matches = []
        
        for specialty in specialties:
            try:
                providers = db_client.get_providers_by_specialty(specialty, limit=20)
                all_matches.extend(providers)
            except:
                pass
        
        seen_npis = set()
        unique_providers = []
        for p in all_matches:
            if p['npi'] not in seen_npis:
                seen_npis.add(p['npi'])
                unique_providers.append(p)
        
        return {
            'understood_intent': intent,
            'search_terms': key_terms,
            'recommended_specialties': specialties,
            'providers': unique_providers[:limit],
            'total_found': len(unique_providers)
        }
        
    except Exception as e:
        return {
            'error': f"Error in semantic search: {str(e)}",
            'understood_intent': '',
            'search_terms': [],
            'recommended_specialties': [],
            'providers': []
        }


# Test function
if __name__ == "__main__":
    print("🧪 Testing AI Engine Functions\n")
    print("=" * 60)
    
    # Test 1: Specialty Description
    print("\n📝 Test 1: Generate Specialty Description")
    print("-" * 60)
    test_specialty = "Cardiology"
    print(f"Specialty: {test_specialty}\n")
    description = generate_specialty_description(test_specialty)
    print(description)
    
    # Test 2: Related Specialties
    print("\n\n🔗 Test 2: Suggest Related Specialties")
    print("-" * 60)
    print(f"For specialty: {test_specialty}\n")
    related = suggest_related_specialties(test_specialty, count=3)
    for i, item in enumerate(related, 1):
        print(f"{i}. {item['specialty']}")
        print(f"   → {item['reason']}\n")
    
    # Test 3: Provider Distribution Analysis
    print("\n📊 Test 3: Analyze Provider Distribution")
    print("-" * 60)
    try:
        providers = db_client.get_providers_by_specialty("Cardiology", limit=20)
        if providers:
            print(f"Analyzing {len(providers)} Cardiology providers...\n")
            analysis = analyze_provider_distribution(providers)
            print(analysis)
        else:
            print("No providers found for analysis.")
    except Exception as e:
        print(f"Could not fetch providers: {e}")
        
        
    # Test 4: Symptom-Based Recommendation (NEW!)
    print("\n\n🩺 Test 4: Recommend Provider by Symptoms")
    print("-" * 70)
    test_symptoms = "chest pain, shortness of breath, feeling tired"
    print(f"Symptoms: {test_symptoms}\n")
    recommendation = recommend_provider_by_symptoms(test_symptoms, location_state="TX")
    print(f"Recommended Specialties: {', '.join(recommendation['recommended_specialties'])}")
    print(f"Reasoning: {recommendation['reasoning']}")
    print(f"Urgency Level: {recommendation['urgency_level'].upper()}")
    if recommendation.get('emergency_action'):
        print(f"⚠️  {recommendation['emergency_action']}")
    print(f"\n{recommendation['disclaimer']}")
    if recommendation.get('available_providers'):
        print(f"\nAvailable providers in TX: {len(recommendation['available_providers'])}")
        for i, p in enumerate(recommendation['available_providers'][:3], 1):
            print(f"  {i}. Dr. {p['name']} - {p['city']}, TX")
    
    # Test 5: Semantic Search (NEW!)
    print("\n\n🔍 Test 5: Semantic Search")
    print("-" * 70)
    test_query = "I need help with my elderly parent's memory problems"
    print(f"Query: \"{test_query}\"\n")
    search_results = semantic_search_providers(test_query, limit=5)
    print(f"Intent Understood: {search_results['understood_intent']}")
    print(f"Search Terms: {', '.join(search_results['search_terms'])}")
    print(f"Recommended Specialties: {', '.join(search_results['recommended_specialties'])}")
    print(f"\nFound {search_results['total_found']} matching providers")
    if search_results['providers']:
        print("\nTop matches:")
        for i, p in enumerate(search_results['providers'][:3], 1):
            print(f"  {i}. Dr. {p['name']} - {p['specialty']} ({p['city']}, {p['state']})")
    
    print("\n" + "=" * 70)
    print("✅ All 5 tests complete!")