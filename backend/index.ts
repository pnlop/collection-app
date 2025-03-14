import express, {Request, Response} from "express";
import cors from "cors";
import Search from "@flesh-and-blood/search";
import { DoubleSidedCard } from "@flesh-and-blood/types";
import { cards } from "@flesh-and-blood/cards";
import bodyParser from "body-parser";
import DatabaseService from "./db";


const app = express();
app.use(bodyParser.json());
app.use(cors());

app.listen(3000, () => {
    console.log('Server running on port 3000');
});


app.post('/api/searchCard', (req, res) => {
    const searchQuery = req.body;
    //from @flesh-and-blood/search search.tests.ts
    const doubleSidedCards: DoubleSidedCard[] = cards.map((card) => {
        if (card.oppositeSideCardIdentifier) {
            const oppositeSideCard = cards.find(
                ({ cardIdentifier }) => cardIdentifier === card.oppositeSideCardIdentifier
            );
            if (oppositeSideCard) {

                (card as DoubleSidedCard).oppositeSideCard = oppositeSideCard;
            }
        }
        return card;
    });

    const search = new Search(doubleSidedCards);
    const searchResults = search.search(searchQuery.query);

    res.contentType('application/json')
    res.send(JSON.stringify(searchResults, function(key, value) {
        if(key == 'oppositeSideCard') { 
          return "Double Sided Card (broken behaviour)";
        } else {
          return value;
        };
      }));

});

const dbService = new DatabaseService('cards.db');

// Initialize the database on startup
(async () => {
    try {
        await dbService.initialize();
        console.log('Database initialized successfully');
    } catch (error) {
        console.error('Failed to initialize database:', error);
        process.exit(1);
    }
})();

// Middleware to handle async errors
const asyncHandler = (fn: (req: Request, res: Response) => Promise<any>) => 
    (req: Request, res: Response) => {
        Promise.resolve(fn(req, res)).catch(err => {
            console.error('Error in request:', err);
            res.status(500).json({ 
                error: 'Server error', 
                message: err instanceof Error ? err.message : 'Unknown error' 
            });
        });
    };

// Get all available collections
app.get('/api/collections', asyncHandler(async (req: Request, res: Response) => {
    const collections = dbService.listCollections();
    res.status(200).json({ collections });
}));

// Create a new card in a collection
app.post('/api/collections/:collectionName/cards', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName } = req.params;
    const cardData = req.body;
    
    if (!cardData || typeof cardData !== 'object') {
        return res.status(400).json({ error: 'Invalid card data. Expected JSON object.' });
    }
    
    // Generate an ID if none provided
    if (!cardData.id) {
        cardData.id = Date.now().toString();
    }
    
    const result = await dbService.createOrUpdateCard(collectionName, cardData);
    await dbService.saveDatabase();
    
    res.status(201).json({ 
        success: true, 
        message: 'Card added to collection', 
        card: result 
    });
}));

// Add multiple cards to a collection
app.post('/api/collections/:collectionName/cards/batch', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName } = req.params;
    const { cards } = req.body;
    
    if (!Array.isArray(cards)) {
        return res.status(400).json({ error: 'Invalid data. Expected an array of cards.' });
    }
    
    // Generate IDs for cards that don't have one
    for (const card of cards) {
        if (!card.id) {
            card.id = Date.now().toString() + Math.random().toString(36).substring(2, 9);
        }
    }
    
    const results = await dbService.addCardsToCollection(collectionName, cards);
    await dbService.saveDatabase();
    
    res.status(201).json({ 
        success: true, 
        message: `${results.length} cards added to collection`, 
        count: results.length 
    });
}));

// Get all cards from a collection
app.get('/api/collections/:collectionName/cards', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName } = req.params;
    const cards = await dbService.getAllCards(collectionName);
    
    res.status(200).json({ 
        collection: collectionName, 
        count: cards.length, 
        cards 
    });
}));

// Get a specific card from a collection
app.get('/api/collections/:collectionName/cards/:cardId', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName, cardId } = req.params;
    const card = await dbService.getCardById(collectionName, cardId);
    
    if (!card) {
        return res.status(404).json({ error: 'Card not found' });
    }
    
    res.status(200).json(card);
}));

// Update a card in a collection
app.put('/api/collections/:collectionName/cards/:cardId', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName, cardId } = req.params;
    const cardData = req.body;
    
    if (!cardData || typeof cardData !== 'object') {
        return res.status(400).json({ error: 'Invalid card data. Expected JSON object.' });
    }
    
    // Ensure the ID in the URL matches the card data
    cardData.id = cardId;
    
    const result = await dbService.createOrUpdateCard(collectionName, cardData);
    await dbService.saveDatabase();
    
    res.status(200).json({ 
        success: true, 
        message: 'Card updated', 
        card: result 
    });
}));

// Delete a card from a collection
app.delete('/api/collections/:collectionName/cards/:cardId', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName, cardId } = req.params;
    const deleted = await dbService.deleteCard(collectionName, cardId);
    
    if (!deleted) {
        return res.status(404).json({ error: 'Card not found' });
    }
    
    await dbService.saveDatabase();
    
    res.status(200).json({ 
        success: true, 
        message: 'Card deleted' 
    });
}));

// Delete an entire collection
app.delete('/api/collections/:collectionName', asyncHandler(async (req: Request, res: Response) => {
    const { collectionName } = req.params;
    const deleted = dbService.deleteCollection(collectionName);
    
    if (!deleted) {
        return res.status(404).json({ error: 'Collection not found' });
    }
    
    await dbService.saveDatabase();
    
    res.status(200).json({ 
        success: true, 
        message: 'Collection deleted' 
    });
}));