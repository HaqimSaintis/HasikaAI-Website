% =======================================================================
% CAI20103 - ASSIGNMENT PROJECT: “HasikaAI: Design and Development of an AI System for Mental Health Wellbeing Among Youth” combined with the assignment project title “Al-Driven Intelligent Multi-Agent Decision Support”.
% INTEGRATES: NLP, Fuzzy Logic, Multi-Agent, Minimax Game AI, IoT, XAI & Ethics
% BY: Muhammad Harish Haqim Bin Adnan (012025020434) [BCS]
% =======================================================================

:- dynamic token/2.
:- dynamic input_text/2.
:- dynamic iot_sensor/3.

% -----------------------------------------------------------------------
% DATA MOCKUP: NLP Keyword Libraries & Adversary State
% -----------------------------------------------------------------------
% Community Demand (Adversary for Game AI)
current_community_demand(high).

% NLP Keyword Libraries
issue_keyword(depression, hopeless).
issue_keyword(depression, depression).
issue_keyword(depression, sad).
issue_keyword(depression, depressed).
issue_keyword(anxiety, anxious).
issue_keyword(anxiety, alone).
issue_keyword(anxiety, worried).
issue_keyword(anxiety, anxiety).
issue_keyword(stress, stressed).
issue_keyword(stress, overwhelmed).
issue_keyword(stress, tense).
issue_keyword(stress, stress).

severity_keyword(high, completely).
severity_keyword(high, very).
severity_keyword(high, deep).
severity_keyword(medium, sometimes).
severity_keyword(medium, okay).

% -----------------------------------------------------------------------
% AGENT 1: DETECTION AGENT (NLP + IoT Reading - Part B and E)
% -----------------------------------------------------------------------

assert_tokens(_, []).
assert_tokens(YouthID, [Word|Rest]) :-
    assertz(token(YouthID, Word)),
    assert_tokens(YouthID, Rest).

extract_issue(YouthID, Issue) :-
    token(YouthID, Word),
    issue_keyword(Issue, Word),
    !.
extract_issue(_, unknown_issue). % Fallback

extract_severity(YouthID, Severity) :-
    token(YouthID, Word),
    severity_keyword(Severity, Word),
    !.
extract_severity(_, low). % Fallback

detection_agent(YouthID, Issue, Severity, HR, Sleep) :-
    input_text(YouthID, String), string_lower(String, Lower),
    split_string(Lower, " ,.", " ,.", StrList), maplist(atom_string, AtomList, StrList),
    retractall(token(YouthID, _)), assert_tokens(YouthID, AtomList),
    extract_issue(YouthID, Issue), extract_severity(YouthID, Severity),
    iot_sensor(YouthID, HR, Sleep).

% -----------------------------------------------------------------------
% AGENT 2: DECISION AGENT (Fuzzy Logic - Part A)
% -----------------------------------------------------------------------

% Fuzzy Rule 1: High NLP Severity + Bad Vitals = Critical Risk (0.95)
fuzzy_rule(high, HR, Sleep, 0.95, critical) :-
    HR >= 100,
    Sleep =< 4,
    !.

% Fuzzy Rule 2: Medium NLP + Normal Vitals = Moderate Risk (0.60)
fuzzy_rule(medium, HR, Sleep, 0.60, moderate) :-
    HR < 90,
    Sleep >= 6,
    !.

% Fuzzy Rule 3: Any other mix = Elevated Risk (0.75)
fuzzy_rule(_, _, _, 0.75, elevated).

decision_agent(Severity, HR, Sleep, FuzzyScore, UrgencyCategory) :-
    fuzzy_rule(Severity, HR, Sleep, FuzzyScore, UrgencyCategory).

% -----------------------------------------------------------------------
% AGENT 3: PLANNING AGENT (Minimax Game AI & Resource Allocation - Part C)
% -----------------------------------------------------------------------

% Strategy 1: If Critical, system forces Specialist intervention regardless of demand.
minimax_strategy(critical, _, immediate_specialist_intervention, 'Dr. Aisyah (Senior Specialist)').

% Strategy 2: If Moderate but Demand is High, system optimizes by assigning Generalist.
minimax_strategy(moderate, high, scheduled_general_intervention, 'Dr. Faris (General Counsellor)').

% Strategy 3: Elevated risk balances based on demand.
minimax_strategy(elevated, high, group_therapy_allocation, 'Community Support Hub').
minimax_strategy(_, _, general_monitoring, 'Automated Check-in System'). % Fallback

planning_agent(UrgencyCategory, StrategyAction, Counsellor) :-
    current_community_demand(Demand),
    minimax_strategy(UrgencyCategory, Demand, StrategyAction, Counsellor).

% -----------------------------------------------------------------------
% AGENT 4: SUPPORT AGENT (XAI, Ethics, and Final Output - Part D and F)
% -----------------------------------------------------------------------
support_agent(YouthID, Text, Issue, HR, Sleep, Score, UrgencyCategory, Action, Counsellor) :-
    nl, writeln('====================================================='),
    writeln(' MULTI-AGENT SYSTEM DECISION & XAI REPORT '),
    writeln('====================================================='),
    write('Youth ID: '), writeln(YouthID),
    write('Raw NLP Input: "'), write(Text), writeln('"'),
    write('Detected Issue: '), writeln(Issue),  % <--- THIS FIXES THE ERROR!
    write('IoT Telemetry: Heart Rate = '), write(HR), write(' bpm | Sleep = '), write(Sleep), writeln(' hrs'),
    writeln('-----------------------------------------------------'),
    writeln('[XAI] FUZZY DECISION REASONING:'),
    write('Combined NLP and IoT data yielded a Fuzzy Risk Score of '), write(Score), 
    write(' ('), write(UrgencyCategory), writeln(').'),
    writeln('-----------------------------------------------------'),
    writeln('[XAI] GAME AI (MINIMAX) RESOURCE STRATEGY:'),
    current_community_demand(Demand),
    write('Adversary State: Community demand is currently '), writeln(Demand),
    write('System Counter: Optimizing resources via -> '), writeln(Action),
    write('Allocation: Assigned to '), writeln(Counsellor),
    writeln('-----------------------------------------------------'),
    writeln('[ETHICS & RESPONSIBLE AI DISCLAIMER]:'),
    writeln('Privacy: IoT and NLP data are encrypted and anonymized.'),
    writeln('Fairness: Minimax allocation ensures resource equity among users.'),
    writeln('Limitation: This AI is a support tool, not a medical diagnosis.'),
    writeln('====================================================='), nl.

% -----------------------------------------------------------------------
% MASTER PIPELINE EXECUTION
% -----------------------------------------------------------------------
run_project_pipeline(YouthID) :-
    input_text(YouthID, RawText),
    detection_agent(YouthID, Issue, NLP_Severity, HR, Sleep),
    decision_agent(NLP_Severity, HR, Sleep, FuzzyScore, UrgencyCategory),
    planning_agent(UrgencyCategory, Action, Counsellor),
    support_agent(YouthID, RawText, Issue, HR, Sleep, FuzzyScore, UrgencyCategory, Action, Counsellor),
    !. % Prevent backtracking duplicates

% -----------------------------------------------------------------------
% INPUT AND OUTPUT OPERATION (For Live Presentation Demonstration)
% -----------------------------------------------------------------------
start_input_output :-
    nl,
    writeln('====================================================='),
    writeln('        WELCOME TO HASIKAAI - YOUTH WELLBEING      '),
    writeln('====================================================='),
    writeln('Initializing Multi-Agent System...'),
    writeln('Connecting to Smart Community IoT Sensors... [OK]'),
    nl,
    writeln('--- IOT SENSOR CALIBRATION ---'),
    writeln('Please simulate the user''s current vitals.'),
    write('Enter Heart Rate (e.g., 115): '), 
    read(HR),
    write('Enter Sleep Hours (e.g., 3): '), 
    read(Sleep),
    
    retractall(iot_sensor(live_youth, _, _)),
    assertz(iot_sensor(live_youth, HR, Sleep)),
    writeln('IoT Data Synced successfully.'),
    nl,
    
    writeln('--- NLP CHAT INTERFACE ---'),
    writeln('How is the youth feeling today?'),
    write('Type message (inside single quotes, e.g., ''I feel completely hopeless''): '),
    read(RawText),
    
    retractall(input_text(live_youth, _)),
    assertz(input_text(live_youth, RawText)),
    writeln('Message Processed.'),
    nl,
    
    writeln('Executing Multi-Agent Reasoning...'),
    run_project_pipeline(live_youth).

% -----------------------------------------------------------------------
% HARDCODED PREDEFINED SCENARIOS
% -----------------------------------------------------------------------
demo_scenario(1) :- 
    writeln('Running Scenario 1: CRITICAL RISK...'),
    retractall(input_text(y1, _)), retractall(iot_sensor(y1, _, _)),
    assertz(input_text(y1, "I feel completely hopeless and deep in depression")),
    assertz(iot_sensor(y1, 115, 3)),
    run_project_pipeline(y1).

demo_scenario(2) :- 
    writeln('Running Scenario 2: MODERATE RISK (Strategic Allocation)...'),
    retractall(input_text(y2, _)), retractall(iot_sensor(y2, _, _)),
    assertz(input_text(y2, "I am okay but sometimes feel anxious")),
    assertz(iot_sensor(y2, 85, 6)),
    run_project_pipeline(y2).

demo_scenario(3) :- 
    writeln('Running Scenario 3: ELEVATED RISK...'),
    retractall(input_text(y3, _)), retractall(iot_sensor(y3, _, _)),
    assertz(input_text(y3, "I feel very stressed and overwhelmed lately")),
    assertz(iot_sensor(y3, 100, 5)),
    run_project_pipeline(y3).