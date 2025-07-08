#!/usr/bin/env python3
"""
Comprehensive Lesson Generator for SpiritGuide
Generates 200 lessons for each religion (Islam, Christianity, Hinduism) with:
- Historical references and context
- Sacred text quotes (Quran, Bible, Bhagavad Gita)
- Progressive difficulty levels
- Practical applications
- Cultural and theological depth
"""

import asyncio
import json
import os
from typing import Dict, List
from dotenv import load_dotenv
from openai import OpenAI
from sqlalchemy.orm import Session
from models import Lesson, Religion, SessionLocal, create_tables
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ComprehensiveLessonGenerator:
    def __init__(self):
        load_dotenv()
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        
        # Lesson topics organized by religion and difficulty
        self.lesson_topics = {
            "Islam": {
                "beginner": [
                    "Introduction to Islam and the Prophet Muhammad",
                    "The Five Pillars of Islam - Foundation of Faith",
                    "Shahada: Declaration of Faith and Its Meaning",
                    "Salah: The Five Daily Prayers and Their Significance",
                    "Zakat: Charity and Social Responsibility in Islam",
                    "Sawm: Fasting During Ramadan and Spiritual Purification",
                    "Hajj: The Pilgrimage to Mecca and Unity of Believers",
                    "The Quran: Structure, Revelation, and Guidance",
                    "Sunnah: Following the Prophet's Example",
                    "Tawhid: The Oneness of Allah",
                    "Angels in Islam: Belief and Their Roles",
                    "Day of Judgment: Accountability and Afterlife",
                    "Prophets in Islam: From Adam to Muhammad",
                    "Islamic Calendar and Holy Days",
                    "Wudu: Ritual Purification and Cleanliness",
                    "Mosque: Architecture and Community Center",
                    "Adhan: The Call to Prayer",
                    "Qibla: Direction of Prayer and Unity",
                    "Halal and Haram: Permitted and Forbidden",
                    "Islamic Greetings and Etiquette",
                    "Family Values in Islam",
                    "Marriage in Islam: Rights and Responsibilities",
                    "Children and Education in Islamic Tradition",
                    "Hospitality in Islamic Culture",
                    "Islamic Art and Calligraphy",
                    "The Kaaba: Sacred House of Allah",
                    "Mecca and Medina: Holy Cities",
                    "Islamic Months and Their Significance",
                    "Dua: Personal Prayer and Supplication",
                    "Dhikr: Remembrance of Allah",
                    "Patience (Sabr) in Islamic Teaching",
                    "Gratitude (Shukr) and Contentment",
                    "Forgiveness in Islam",
                    "Justice and Fairness in Islamic Ethics",
                    "Compassion and Mercy in Islam",
                    "Islamic Dietary Laws and Wisdom",
                    "Cleanliness and Hygiene in Islam",
                    "Islamic Banking and Finance Principles",
                    "Charity Beyond Zakat: Sadaqah",
                    "Islamic Calendar Events and Celebrations",
                    "The Night Journey (Isra and Mi'raj)",
                    "Battle of Badr: Faith and Victory",
                    "Treaty of Hudaybiyyah: Diplomacy and Peace",
                    "Conquest of Mecca: Forgiveness and Unity",
                    "Farewell Pilgrimage: Final Teachings",
                    "Companions of the Prophet: Examples of Faith",
                    "Abu Bakr: The Truthful Companion",
                    "Umar ibn al-Khattab: Justice and Leadership",
                    "Uthman ibn Affan: Generosity and Compilation of Quran",
                    "Ali ibn Abi Talib: Wisdom and Courage",
                    "Aisha: Mother of Believers and Scholar",
                    "Khadijah: First Believer and Supporter",
                    "Fatimah: Daughter of the Prophet",
                    "Islamic Civilization: Golden Age Achievements",
                    "Science and Medicine in Islamic History",
                    "Philosophy and Theology in Islam",
                    "Islamic Literature and Poetry",
                    "Sufi Tradition: Mystical Path in Islam",
                    "Islamic Law (Sharia): Principles and Applications",
                    "Jihad: Struggle and True Meaning",
                    "Islamic Governance and Leadership",
                    "Women's Rights in Islam",
                    "Environmental Stewardship in Islam",
                    "Islamic Contributions to Mathematics",
                    "Islamic Architecture and Design",
                    "Trade and Commerce in Islamic History",
                    "Islamic Education and Learning",
                    "Interfaith Relations in Islam",
                    "Islam and Modern Challenges"
                ],
                "intermediate": [
                    "Quranic Exegesis (Tafsir): Understanding Divine Revelation",
                    "Hadith Sciences: Preservation of Prophetic Traditions",
                    "Islamic Jurisprudence (Fiqh): Legal Methodology",
                    "The Four Schools of Islamic Law",
                    "Ijtihad: Independent Reasoning in Islam",
                    "Ijma: Consensus in Islamic Decision Making",
                    "Qiyas: Analogical Reasoning in Islamic Law",
                    "Maqasid al-Shariah: Objectives of Islamic Law",
                    "Islamic Theology (Aqidah): Core Beliefs",
                    "Predestination (Qadar) and Free Will",
                    "Names and Attributes of Allah (Asma ul-Husna)",
                    "Prophethood (Nubuwwah) in Islamic Theology",
                    "Miracles and Signs in Islamic Belief",
                    "Islamic Eschatology: End Times and Afterlife",
                    "Soul and Spirit in Islamic Understanding",
                    "Islamic Psychology and Human Nature",
                    "Spiritual Purification (Tazkiyah)",
                    "Islamic Ethics (Akhlaq) and Character Building",
                    "Patience and Perseverance in Trials",
                    "Humility and Pride in Islamic Teaching",
                    "Islamic Concept of Time and Eternity",
                    "Covenant and Trust in Islam",
                    "Islamic Understanding of Knowledge",
                    "Wisdom Literature in Islamic Tradition",
                    "Islamic Mysticism: Sufi Teachings",
                    "Spiritual Stations (Maqamat) in Sufism",
                    "Islamic Meditation and Contemplation",
                    "Heart Purification in Islamic Spirituality",
                    "Islamic Concept of Love and Devotion",
                    "Unity of Being in Islamic Mysticism",
                    "Islamic Philosophy: Reason and Revelation",
                    "Al-Ghazali: Reconciling Faith and Reason",
                    "Ibn Sina (Avicenna): Islamic Philosophy",
                    "Ibn Rushd (Averroes): Rationalist Tradition",
                    "Islamic Political Theory",
                    "Caliphate: Leadership and Governance",
                    "Shura: Consultation in Islamic Governance",
                    "Islamic Economic Principles",
                    "Prohibition of Interest (Riba) in Islam",
                    "Islamic Contract Law",
                    "Waqf: Religious Endowments",
                    "Islamic Social Justice",
                    "Rights of Minorities in Islam",
                    "Islamic International Law",
                    "War and Peace in Islamic Ethics",
                    "Islamic Environmental Ethics",
                    "Stewardship (Khilafah) of Earth",
                    "Islamic Medical Ethics",
                    "Bioethics in Islamic Perspective",
                    "Islamic Art and Aesthetics",
                    "Geometric Patterns in Islamic Art",
                    "Islamic Music and Spirituality",
                    "Islamic Literature: Classical Works",
                    "Arabic Language and Islamic Culture",
                    "Islamic Historiography",
                    "Sectarian Differences in Islam",
                    "Sunni and Shia: Historical Development",
                    "Islamic Reform Movements",
                    "Modernist Thought in Islam",
                    "Islam and Science: Historical Relationship",
                    "Islamic Contributions to Astronomy",
                    "Islamic Medicine and Hospitals",
                    "Islamic Educational Institutions",
                    "Madrasas: Traditional Islamic Schools",
                    "Islamic Universities: Al-Azhar and Others",
                    "Islamic Scholarship: Methods and Traditions",
                    "Women Scholars in Islamic History",
                    "Islamic Feminism and Gender Studies",
                    "Islam in the Modern World"
                ],
                "advanced": [
                    "Advanced Quranic Studies: Linguistic Miracles",
                    "Hadith Criticism: Methodology and Authentication",
                    "Comparative Islamic Jurisprudence",
                    "Contemporary Issues in Islamic Law",
                    "Islamic Banking: Modern Applications",
                    "Bioethics and Islamic Medical Jurisprudence",
                    "Islamic Environmental Law",
                    "Human Rights in Islamic Perspective",
                    "Islamic Feminism: Contemporary Debates",
                    "Islam and Democracy: Theoretical Frameworks",
                    "Islamic Economics: Alternative Models",
                    "Globalization and Islamic Identity",
                    "Islamic Revivalism: Modern Movements",
                    "Salafism: Methodology and Influence",
                    "Islamic Modernism: Intellectual Traditions",
                    "Sufism in Contemporary World",
                    "Islamic Psychology: Modern Applications",
                    "Islamic Counseling and Therapy",
                    "Islam and Interfaith Dialogue",
                    "Islamic Theology: Contemporary Challenges",
                    "Evolution and Islamic Thought",
                    "Islam and Technology: Ethical Considerations",
                    "Islamic Media and Communication",
                    "Islamic Education: Modern Challenges",
                    "Islamic Leadership: Contemporary Models",
                    "Islam and Social Media: Opportunities and Challenges",
                    "Islamic Finance: Global Markets",
                    "Islamic Insurance (Takaful)",
                    "Islamic Real Estate and Investment",
                    "Islamic Corporate Governance",
                    "Islam and Artificial Intelligence",
                    "Islamic Ethics in Digital Age",
                    "Muslim Minorities: Identity and Integration",
                    "Islam in Western Societies",
                    "Islamic Chaplaincy: Modern Role",
                    "Islamic Social Work",
                    "Islam and Mental Health",
                    "Islamic Approaches to Conflict Resolution",
                    "Islam and Peacebuilding",
                    "Islamic Humanitarian Law",
                    "Islam and Climate Change",
                    "Islamic Sustainable Development",
                    "Islam and Renewable Energy",
                    "Islamic Urban Planning",
                    "Islamic Architecture: Modern Expressions",
                    "Islam and Contemporary Art",
                    "Islamic Literature: Modern Voices",
                    "Islam and Cinema",
                    "Islamic Music: Contemporary Expressions",
                    "Islam and Sports Ethics",
                    "Islamic Tourism and Pilgrimage",
                    "Halal Industry: Global Perspectives",
                    "Islamic Fashion and Modesty",
                    "Islam and Food Culture",
                    "Islamic Parenting: Modern Challenges",
                    "Islamic Marriage: Contemporary Issues",
                    "Islamic Divorce and Family Law",
                    "Islam and Elderly Care",
                    "Islamic End-of-Life Care",
                    "Islam and Organ Donation",
                    "Islamic Perspectives on Genetic Engineering",
                    "Islam and Space Exploration",
                    "Islamic Astronomy: Modern Developments",
                    "Islam and Quantum Physics",
                    "Islamic Philosophy: Contemporary Debates",
                    "Islam and Postmodernism",
                    "Islamic Hermeneutics: Modern Approaches"
                ]
            },
            "Christianity": {
                "beginner": [
                    "Introduction to Christianity and Jesus Christ",
                    "The Life of Jesus: Birth, Ministry, and Crucifixion",
                    "The Resurrection: Victory Over Death",
                    "The Trinity: Father, Son, and Holy Spirit",
                    "The Bible: Old and New Testament",
                    "Gospel of Matthew: Jesus as King",
                    "Gospel of Mark: Jesus as Servant",
                    "Gospel of Luke: Jesus as Perfect Man",
                    "Gospel of John: Jesus as Son of God",
                    "Acts of the Apostles: Early Church",
                    "Paul's Letters: Theology and Practice",
                    "The Ten Commandments: Moral Foundation",
                    "The Beatitudes: Blessed Are Those Who...",
                    "The Lord's Prayer: Our Father in Heaven",
                    "The Great Commandment: Love God and Neighbor",
                    "The Great Commission: Go and Make Disciples",
                    "Salvation by Grace Through Faith",
                    "Baptism: Symbol of New Life",
                    "Communion: Remembering Christ's Sacrifice",
                    "Prayer: Communicating with God",
                    "Worship: Praising God in Spirit and Truth",
                    "Christian Holidays: Christmas and Easter",
                    "The Church: Body of Christ",
                    "Christian Community and Fellowship",
                    "Christian Service and Mission",
                    "Christian Ethics and Morality",
                    "Love and Forgiveness in Christianity",
                    "Faith, Hope, and Charity",
                    "Christian Marriage and Family",
                    "Christian Parenting and Children",
                    "Christian Work and Calling",
                    "Christian Stewardship and Giving",
                    "Christian Hospitality and Welcome",
                    "Christian Peacemaking and Reconciliation",
                    "Christian Care for the Poor",
                    "Christian Environmental Stewardship",
                    "Christian Art and Beauty",
                    "Christian Music and Hymns",
                    "Christian Literature and Poetry",
                    "Christian Symbols and Traditions",
                    "Christian Calendar and Seasons",
                    "Advent: Preparing for Christ's Coming",
                    "Lent: Season of Repentance",
                    "Holy Week: Passion of Christ",
                    "Pentecost: Gift of the Holy Spirit",
                    "Saints and Christian Heroes",
                    "Mary, Mother of Jesus",
                    "John the Baptist: Forerunner of Christ",
                    "Peter: Rock of the Church",
                    "Paul: Apostle to the Gentiles",
                    "John: Beloved Disciple",
                    "Mary Magdalene: First Witness",
                    "Stephen: First Martyr",
                    "Early Church Fathers",
                    "Augustine: Grace and Conversion",
                    "Francis of Assisi: Poverty and Service",
                    "Thomas Aquinas: Faith and Reason",
                    "Martin Luther: Reformation",
                    "John Calvin: Sovereignty of God",
                    "John Wesley: Methodist Revival",
                    "Mother Teresa: Service to the Poor",
                    "Dietrich Bonhoeffer: Faith and Resistance",
                    "C.S. Lewis: Reason and Imagination",
                    "Billy Graham: Evangelism and Preaching",
                    "Desmond Tutu: Justice and Reconciliation",
                    "Christian Denominations: Unity in Diversity",
                    "Catholic Church: Tradition and Authority",
                    "Orthodox Churches: Eastern Christianity"
                ],
                "intermediate": [
                    "Biblical Hermeneutics: Interpreting Scripture",
                    "Christian Theology: Systematic Study",
                    "Christology: Person and Work of Christ",
                    "Pneumatology: Doctrine of the Holy Spirit",
                    "Soteriology: Doctrine of Salvation",
                    "Ecclesiology: Doctrine of the Church",
                    "Eschatology: Last Things and End Times",
                    "Christian Apologetics: Defending the Faith",
                    "Natural Theology: Reason and Revelation",
                    "Christian Philosophy: Athens and Jerusalem",
                    "Christian Ethics: Moral Theology",
                    "Christian Mysticism: Union with God",
                    "Christian Spirituality: Life in the Spirit",
                    "Christian Discipleship: Following Jesus",
                    "Christian Formation: Growing in Faith",
                    "Christian Education: Teaching the Faith",
                    "Christian Worship: Liturgy and Praise",
                    "Christian Preaching: Proclaiming the Word",
                    "Christian Pastoral Care: Shepherding Souls",
                    "Christian Counseling: Healing and Wholeness",
                    "Christian Social Ethics: Faith and Justice",
                    "Christian Political Theology",
                    "Christian Economic Ethics",
                    "Christian Medical Ethics",
                    "Christian Environmental Ethics",
                    "Christian Sexual Ethics",
                    "Christian Bioethics",
                    "Christian Just War Theory",
                    "Christian Pacifism and Non-violence",
                    "Christian Liberation Theology",
                    "Christian Feminist Theology",
                    "Christian Black Theology",
                    "Christian Contextual Theology",
                    "Christian Interfaith Relations",
                    "Christian Mission and Evangelism",
                    "Christian Ecumenism: Unity Movement",
                    "Christian Reformation: Historical Impact",
                    "Christian Counter-Reformation",
                    "Christian Enlightenment: Faith and Reason",
                    "Christian Romanticism: Emotion and Faith",
                    "Christian Modernism: Adaptation to Modernity",
                    "Christian Fundamentalism: Biblical Literalism",
                    "Christian Pentecostalism: Gifts of the Spirit",
                    "Christian Evangelicalism: Gospel Emphasis",
                    "Christian Liberalism: Progressive Christianity",
                    "Christian Orthodoxy: Traditional Faith",
                    "Christian Monasticism: Religious Life",
                    "Christian Martyrdom: Witness unto Death",
                    "Christian Pilgrimage: Spiritual Journey",
                    "Christian Sacraments: Means of Grace",
                    "Christian Liturgical Year: Sacred Time",
                    "Christian Architecture: Sacred Space",
                    "Christian Iconography: Visual Theology",
                    "Christian Literature: Sacred and Secular",
                    "Christian Drama: Mystery and Morality Plays",
                    "Christian Philosophy of History",
                    "Christian Anthropology: Human Nature",
                    "Christian Cosmology: God and Creation",
                    "Christian Theodicy: Problem of Evil",
                    "Christian Miracles: Signs and Wonders",
                    "Christian Prophecy: Foretelling and Forth-telling",
                    "Christian Healing: Divine and Human",
                    "Christian Exorcism: Spiritual Warfare",
                    "Christian Discernment: Spiritual Wisdom",
                    "Christian Contemplation: Seeing God",
                    "Christian Action: Faith in Practice",
                    "Christian Witness: Living the Gospel"
                ],
                "advanced": [
                    "Advanced Biblical Criticism: Historical and Literary",
                    "Postmodern Christian Theology",
                    "Process Theology: God in Becoming",
                    "Narrative Theology: Story and Faith",
                    "Radical Orthodoxy: Theological Movement",
                    "Christian Deconstructionism",
                    "Feminist Biblical Hermeneutics",
                    "Postcolonial Biblical Interpretation",
                    "Queer Theology: LGBTQ+ and Christianity",
                    "Disability Theology: Embodiment and Faith",
                    "Eco-Theology: Creation and Sustainability",
                    "Digital Theology: Faith in Cyber Age",
                    "Neurotheology: Brain and Religious Experience",
                    "Christian Transhumanism: Technology and Faith",
                    "Christian Artificial Intelligence Ethics",
                    "Christian Space Theology: Cosmic Perspective",
                    "Christian Quantum Theology: Science and Faith",
                    "Christian Evolutionary Theology",
                    "Christian Genetic Ethics",
                    "Christian Stem Cell Research Ethics",
                    "Christian End-of-Life Care Ethics",
                    "Christian Organ Donation Ethics",
                    "Christian Mental Health Ministry",
                    "Christian Addiction Recovery",
                    "Christian Trauma Therapy",
                    "Christian Grief Counseling",
                    "Christian Marriage Counseling",
                    "Christian Family Therapy",
                    "Christian Youth Ministry",
                    "Christian Elderly Care Ministry",
                    "Christian Prison Ministry",
                    "Christian Hospital Chaplaincy",
                    "Christian Military Chaplaincy",
                    "Christian Campus Ministry",
                    "Christian Urban Ministry",
                    "Christian Rural Ministry",
                    "Christian International Development",
                    "Christian Disaster Relief",
                    "Christian Refugee Ministry",
                    "Christian Anti-Trafficking Work",
                    "Christian Peacebuilding",
                    "Christian Reconciliation Ministry",
                    "Christian Restorative Justice",
                    "Christian Community Development",
                    "Christian Microfinance",
                    "Christian Fair Trade",
                    "Christian Sustainable Agriculture",
                    "Christian Renewable Energy",
                    "Christian Climate Action",
                    "Christian Conservation",
                    "Christian Animal Welfare",
                    "Christian Food Justice",
                    "Christian Housing Ministry",
                    "Christian Healthcare Ministry",
                    "Christian Education Reform",
                    "Christian Media Ministry",
                    "Christian Arts Ministry",
                    "Christian Sports Ministry",
                    "Christian Business Ethics",
                    "Christian Corporate Responsibility",
                    "Christian Investment Ethics",
                    "Christian Nonprofit Management",
                    "Christian Leadership Development",
                    "Christian Organizational Ethics",
                    "Christian Conflict Resolution",
                    "Christian Mediation",
                    "Christian Arbitration",
                    "Christian Legal Ethics"
                ]
            },
            "Hinduism": {
                "beginner": [
                    "Introduction to Hinduism: Ancient Wisdom Tradition",
                    "The Vedas: Foundation of Hindu Knowledge",
                    "Upanishads: Philosophical Teachings",
                    "The Bhagavad Gita: Song of the Divine",
                    "Ramayana: Epic of Virtue and Devotion",
                    "Mahabharata: Great Epic of Ancient India",
                    "Puranas: Stories of Gods and Goddesses",
                    "Dharma: Righteous Living and Duty",
                    "Karma: Law of Action and Consequence",
                    "Samsara: Cycle of Birth and Rebirth",
                    "Moksha: Liberation from Cycle of Rebirth",
                    "Atman: Individual Soul and Self",
                    "Brahman: Universal Spirit and Reality",
                    "Om: Sacred Sound and Symbol",
                    "Yoga: Union of Body, Mind, and Spirit",
                    "Meditation: Path to Inner Peace",
                    "Pranayama: Breath Control and Energy",
                    "Mantras: Sacred Sounds and Chants",
                    "Puja: Worship and Devotional Practice",
                    "Aarti: Light Ceremony and Devotion",
                    "Pilgrimage: Sacred Journeys and Sites",
                    "Temples: Sacred Architecture and Worship",
                    "Festivals: Celebrations of Divine",
                    "Diwali: Festival of Lights",
                    "Holi: Festival of Colors",
                    "Navaratri: Nine Nights of Divine Mother",
                    "Janmashtami: Birth of Lord Krishna",
                    "Rama Navami: Birth of Lord Rama",
                    "Shivaratri: Night of Lord Shiva",
                    "Ganesha Chaturthi: Remover of Obstacles",
                    "Guru Purnima: Honoring the Teacher",
                    "Brahma: Creator of Universe",
                    "Vishnu: Preserver and Protector",
                    "Shiva: Destroyer and Transformer",
                    "Devi: Divine Mother and Shakti",
                    "Krishna: Divine Love and Wisdom",
                    "Rama: Ideal King and Righteousness",
                    "Ganesha: Remover of Obstacles",
                    "Hanuman: Devotion and Strength",
                    "Saraswati: Goddess of Knowledge",
                    "Lakshmi: Goddess of Prosperity",
                    "Durga: Divine Mother Warrior",
                    "Kali: Fierce Aspect of Divine Mother",
                    "Avatars: Divine Incarnations",
                    "Dashavatar: Ten Incarnations of Vishnu",
                    "Caste System: Social Structure and Reform",
                    "Ashrama: Four Stages of Life",
                    "Varna: Four Classes of Society",
                    "Samskaras: Sacred Rituals and Ceremonies",
                    "Marriage: Sacred Union and Partnership",
                    "Family: Foundation of Society",
                    "Guru: Spiritual Teacher and Guide",
                    "Disciple: Student and Seeker",
                    "Seva: Selfless Service",
                    "Ahimsa: Non-violence and Compassion",
                    "Truthfulness: Satya and Honesty",
                    "Vegetarianism: Compassion for All Life",
                    "Sacred Cow: Reverence for Life",
                    "Ganges: Sacred River and Purification",
                    "Varanasi: Holy City and Spiritual Center",
                    "Rishikesh: Yoga Capital of the World",
                    "Vrindavan: Land of Lord Krishna",
                    "Ayodhya: Birthplace of Lord Rama",
                    "Tirupati: Abode of Lord Venkateswara",
                    "Kashi Vishwanath: Temple of Lord Shiva",
                    "Kedarnath: Sacred Himalayan Shrine",
                    "Badrinath: Abode of Lord Vishnu"
                ],
                "intermediate": [
                    "Vedantic Philosophy: Schools of Thought",
                    "Advaita Vedanta: Non-dualism",
                    "Dvaita Vedanta: Dualism",
                    "Vishishtadvaita: Qualified Non-dualism",
                    "Sankhya Philosophy: Dualistic System",
                    "Yoga Philosophy: Eight-Limbed Path",
                    "Nyaya Philosophy: Logic and Reasoning",
                    "Vaisheshika Philosophy: Atomistic Theory",
                    "Mimamsa Philosophy: Ritual Interpretation",
                    "Charvaka Philosophy: Materialist School",
                    "Tantra: Esoteric Spiritual Practice",
                    "Kundalini: Spiritual Energy and Awakening",
                    "Chakras: Energy Centers in Body",
                    "Ayurveda: Traditional Medicine System",
                    "Jyotisha: Vedic Astrology",
                    "Vastu Shastra: Sacred Architecture",
                    "Sanskrit: Sacred Language",
                    "Vedic Mathematics: Ancient Calculations",
                    "Classical Music: Spiritual Expression",
                    "Classical Dance: Divine Movement",
                    "Bhakti Yoga: Path of Devotion",
                    "Karma Yoga: Path of Action",
                    "Jnana Yoga: Path of Knowledge",
                    "Raja Yoga: Royal Path of Meditation",
                    "Hatha Yoga: Physical Practices",
                    "Kriya Yoga: Technique of Purification",
                    "Bhakti Movement: Devotional Renaissance",
                    "Sufi-Hindu Synthesis: Mystical Unity",
                    "Kabir: Mystic Poet and Saint",
                    "Mirabai: Devotional Poetess",
                    "Tulsidas: Author of Ramcharitmanas",
                    "Surdas: Krishna Devotee Poet",
                    "Chaitanya: Ecstatic Devotion",
                    "Ramanuja: Qualified Non-dualism",
                    "Madhva: Dualistic Philosophy",
                    "Shankara: Advaita Vedanta",
                    "Ramana Maharshi: Self-Inquiry",
                    "Ramakrishna: God-Realization",
                    "Vivekananda: Vedanta in Modern World",
                    "Gandhi: Truth and Non-violence",
                    "Aurobindo: Integral Yoga",
                    "Yogananda: Kriya Yoga in West",
                    "Krishnamurti: Freedom from Known",
                    "Osho: Meditation and Awareness",
                    "Sadhguru: Inner Engineering",
                    "Amma: Hugging Saint",
                    "Satsang: Spiritual Gathering",
                    "Darshan: Seeing the Divine",
                    "Prasad: Blessed Food",
                    "Tilaka: Sacred Marks",
                    "Rudraksha: Sacred Beads",
                    "Yantra: Sacred Geometry",
                    "Mudra: Sacred Hand Gestures",
                    "Bandha: Energy Locks",
                    "Pranayama: Advanced Breathing",
                    "Samadhi: Absorption in Divine",
                    "Satsang: Company of Truth",
                    "Tapas: Spiritual Discipline",
                    "Vrata: Sacred Vows",
                    "Yatra: Pilgrimage Journey",
                    "Kumbh Mela: Grand Spiritual Gathering",
                    "Char Dham: Four Sacred Abodes",
                    "Twelve Jyotirlingas: Sacred Shiva Temples",
                    "Shakti Peethas: Divine Mother Temples",
                    "Divya Desams: Sacred Vishnu Temples",
                    "Sacred Geography: Spiritual Landscape"
                ],
                "advanced": [
                    "Kashmir Shaivism: Consciousness Philosophy",
                    "Trika System: Threefold Classification",
                    "Spanda Philosophy: Dynamic Consciousness",
                    "Pratyabhijna: Recognition Philosophy",
                    "Advaita Vedanta: Advanced Non-dualism",
                    "Mandukya Upanishad: States of Consciousness",
                    "Ashtavakra Gita: Pure Awareness",
                    "Ribhu Gita: Self-Realization",
                    "Yoga Vasistha: Consciousness and Reality",
                    "Bhagavata Purana: Divine Love",
                    "Devi Bhagavata: Divine Feminine",
                    "Tantric Philosophy: Energy and Consciousness",
                    "Shri Vidya: Supreme Knowledge",
                    "Mahavidyas: Ten Wisdom Goddesses",
                    "Kundalini Yoga: Advanced Practices",
                    "Nada Yoga: Sound Meditation",
                    "Laya Yoga: Dissolution Practices",
                    "Sahaja Yoga: Natural State",
                    "Integral Yoga: Synthesis of Paths",
                    "Jnana Yoga: Advanced Self-Inquiry",
                    "Advaitic Meditation: Pure Awareness",
                    "Witness Consciousness: Sakshi Bhava",
                    "Nirvikalpa Samadhi: Formless Absorption",
                    "Sahaja Samadhi: Natural State",
                    "Turiya: Fourth State of Consciousness",
                    "Atma Vichara: Self-Investigation",
                    "Neti Neti: Not This, Not This",
                    "Tat Tvam Asi: Thou Art That",
                    "Aham Brahmasmi: I Am Brahman",
                    "Sarvam Khalvidam Brahma: All Is Brahman",
                    "Maya: Cosmic Illusion",
                    "Lila: Divine Play",
                    "Rasa: Aesthetic Flavor",
                    "Bhava: Emotional States",
                    "Prema: Divine Love",
                    "Karuna: Compassion",
                    "Mudita: Sympathetic Joy",
                    "Upekkha: Equanimity",
                    "Viveka: Discrimination",
                    "Vairagya: Dispassion",
                    "Shraddha: Faith",
                    "Bhakti: Devotion",
                    "Surrender: Sharanagati",
                    "Grace: Anugraha",
                    "Guru Tattva: Principle of Teacher",
                    "Shaktipat: Transmission of Energy",
                    "Initiation: Diksha",
                    "Mantra Yoga: Advanced Sound Practice",
                    "Japa: Repetitive Chanting",
                    "Ajapa: Spontaneous Repetition",
                    "Soham: I Am That",
                    "Hamsa: Swan Breath",
                    "Gayatri: Universal Prayer",
                    "Mahamrityunjaya: Death-Conquering Mantra",
                    "Shri Yantra: Supreme Geometric Form",
                    "Mandala: Sacred Circle",
                    "Chakra Meditation: Energy Centers",
                    "Bindu: Point of Consciousness",
                    "Nada: Cosmic Sound",
                    "Shabda Brahman: Sound as Brahman",
                    "Vak: Sacred Speech",
                    "Silence: Mauna",
                    "Contemplation: Nididhyasana",
                    "Reflection: Manana",
                    "Study: Svadhyaya",
                    "Service: Seva"
                ]
            }
        }
    
    def get_enhanced_prompt(self, religion: str, topic: str, difficulty: str) -> str:
        """Generate enhanced prompt for high-quality lessons with sacred text quotes"""
        
        sacred_texts = {
            "Islam": "Quran",
            "Christianity": "Bible",
            "Hinduism": "Bhagavad Gita, Upanishads, and Vedas"
        }
        
        historical_focus = {
            "Islam": "Islamic civilization, Prophet Muhammad's life, companions, Islamic golden age, and historical developments",
            "Christianity": "Life of Jesus, early church, church fathers, reformation, and Christian history",
            "Hinduism": "Ancient Vedic period, great epics, philosophical developments, and spiritual masters"
        }
        
        return f"""You are an expert religious scholar and educator creating a comprehensive lesson on {topic} for {religion} at {difficulty} level.

CRITICAL REQUIREMENTS:
1. SACRED TEXT QUOTES: Include at least 3-5 direct quotes from {sacred_texts[religion]} with proper citations
2. HISTORICAL CONTEXT: Provide rich historical background and references from {historical_focus[religion]}
3. PRACTICAL APPLICATION: Include specific, actionable practices for daily life
4. CULTURAL DEPTH: Explain cultural significance and traditions
5. SCHOLARLY ACCURACY: Use only verified, academic sources

LESSON STRUCTURE:
- Title: Engaging and descriptive
- Introduction: Hook the reader with relevance
- Historical Context: Rich background (15-20% of content)
- Sacred Text Integration: Weave quotes naturally throughout
- Core Teaching: Main concepts with depth
- Practical Applications: Real-world implementation
- Cultural Significance: Traditions and customs
- Reflection Questions: Thought-provoking queries
- Further Study: Additional resources

DIFFICULTY LEVEL REQUIREMENTS:
- Beginner: Basic concepts, simple language, foundational knowledge
- Intermediate: Deeper analysis, theological concepts, historical complexity
- Advanced: Scholarly discourse, comparative analysis, contemporary applications

SACRED TEXT CITATION FORMAT:
- Islam: "Quote text" (Quran Chapter:Verse)
- Christianity: "Quote text" (Book Chapter:Verse)
- Hinduism: "Quote text" (Text Name Chapter.Verse)

HISTORICAL REFERENCE REQUIREMENTS:
- Include specific dates, names, and events
- Explain historical significance
- Connect past to present relevance
- Use primary and secondary sources

QUALITY STANDARDS:
- 1000-1500 words for comprehensive coverage
- Academic rigor with accessible language
- Culturally sensitive and respectful
- Factually accurate with proper citations
- Engaging and inspiring tone

Return in JSON format with these exact fields:
{{
    "title": "Lesson title",
    "content": "Full lesson content with sacred quotes and historical references",
    "religion": "{religion}",
    "difficulty": "{difficulty}",
    "duration": "Estimated minutes (8-12 for comprehensive lessons)",
    "practical_task": "Specific, actionable practice for daily life",
    "learning_objectives": "What students will learn and achieve",
    "prerequisites": "Required prior knowledge",
    "sacred_quotes": [
        {{
            "text": "Quote text",
            "citation": "Proper citation",
            "context": "Explanation of relevance"
        }}
    ],
    "historical_references": [
        {{
            "event": "Historical event/person",
            "date": "Time period",
            "significance": "Why it matters"
        }}
    ],
    "sources": [
        {{
            "title": "Source title",
            "author": "Author name",
            "type": "book/article/website",
            "url": "URL if available"
        }}
    ],
    "reflection_questions": [
        "Thought-provoking question 1",
        "Thought-provoking question 2",
        "Thought-provoking question 3"
    ],
    "further_study": [
        "Additional resource 1",
        "Additional resource 2",
        "Additional resource 3"
    ]
}}

Topic: {topic}
Religion: {religion}
Difficulty: {difficulty}

Create a masterpiece lesson that will deeply educate and inspire learners about this sacred tradition."""

    def generate_lesson(self, religion: str, topic: str, difficulty: str) -> Dict:
        """Generate a single comprehensive lesson"""
        try:
            prompt = self.get_enhanced_prompt(religion, topic, difficulty)
            
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "You are a world-class religious scholar and educator."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=4000,
                temperature=0.7,
            )
            
            content = response.choices[0].message.content
            
            # Parse JSON response
            if "{" in content and "}" in content:
                start = content.find("{")
                end = content.rfind("}") + 1
                json_str = content[start:end]
                return json.loads(json_str)
            else:
                logger.error(f"Failed to parse JSON for {religion} - {topic}")
                return {}
                
        except Exception as e:
            logger.error(f"Error generating lesson for {religion} - {topic}: {str(e)}")
            return {}
    
    def generate_all_lessons(self, religion: str) -> List[Dict]:
        """Generate all lessons for a religion"""
        all_lessons = []
        lesson_id = 1
        
        for difficulty in ["beginner", "intermediate", "advanced"]:
            topics = self.lesson_topics[religion][difficulty]
            
            for topic in topics:
                logger.info(f"Generating lesson {lesson_id}: {religion} - {difficulty} - {topic}")
                
                lesson = self.generate_lesson(religion, topic, difficulty)
                if lesson:
                    lesson["id"] = lesson_id
                    lesson["lesson_type"] = "comprehensive"
                    lesson["ai_generated"] = True
                    all_lessons.append(lesson)
                    lesson_id += 1
                    
                    # Add delay to avoid rate limiting
                    import time
                    time.sleep(2)
                else:
                    logger.warning(f"Failed to generate lesson: {topic}")
        
        return all_lessons
    
    def save_lessons_to_file(self, lessons: List[Dict], religion: str):
        """Save lessons to JSON file"""
        filename = f"backend/data/lessons_{religion.lower()}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(lessons, f, indent=2, ensure_ascii=False)
        logger.info(f"Saved {len(lessons)} lessons to {filename}")
    
    def save_lessons_to_database(self, lessons: List[Dict], db: Session):
        """Save lessons to database"""
        for lesson_data in lessons:
            # Convert lesson data to database format
            lesson = Lesson(
                id=lesson_data["id"],
                title=lesson_data["title"],
                content=lesson_data["content"],
                religion=lesson_data["religion"].lower(),
                difficulty=lesson_data["difficulty"],
                duration=int(lesson_data["duration"]),
                practical_task=lesson_data.get("practical_task"),
                learning_objectives=lesson_data.get("learning_objectives"),
                prerequisites=lesson_data.get("prerequisites"),
                lesson_type=lesson_data.get("lesson_type", "comprehensive"),
                ai_generated=lesson_data.get("ai_generated", True),
                sources=lesson_data.get("sources", [])
            )
            db.add(lesson)
        
        db.commit()
        logger.info(f"Saved {len(lessons)} lessons to database")

def main():
    """Main function to generate all lessons"""
    generator = ComprehensiveLessonGenerator()
    
    # Create database tables
    create_tables()
    
    # Generate lessons for each religion
    religions = ["Islam", "Christianity", "Hinduism"]
    
    for religion in religions:
        logger.info(f"Starting lesson generation for {religion}")
        
        # Generate all lessons
        lessons = generator.generate_all_lessons(religion)
        
        if lessons:
            # Save to file
            generator.save_lessons_to_file(lessons, religion)
            
            # Save to database
            db = SessionLocal()
            try:
                generator.save_lessons_to_database(lessons, db)
            finally:
                db.close()
            
            logger.info(f"Completed {religion}: Generated {len(lessons)} lessons")
        else:
            logger.error(f"Failed to generate lessons for {religion}")
    
    logger.info("Lesson generation complete!")

if __name__ == "__main__":
    main() 