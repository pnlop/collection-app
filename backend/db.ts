import loki, { Loki, Collection } from 'lokijs';

class DatabaseService {
    private db: Loki;
    private collections: Map<string, Collection<any>> = new Map();
    private initialized: boolean = false;

    constructor(dbName: string) {
        this.db = new loki(dbName);
    }

    async initialize(): Promise<void> {
        if (this.initialized) return;

        return new Promise((resolve, reject) => {
            this.db.loadDatabase({}, (err) => {
                if (err) {
                    return reject(err);
                }
                this.initialized = true;
                resolve();
            });
        });
    }

    getCollection(collectionName: string): Collection<any> {
        if (this.collections.has(collectionName)) {
            return this.collections.get(collectionName)!;
        }

        let collection = this.db.getCollection(collectionName);

        if (!collection) {
            collection = this.db.addCollection(collectionName, {
                indices: ['id']
            });
        }

        this.collections.set(collectionName, collection);

        return collection;
    }

    listCollections(): string[] {
        return this.db.listCollections().map(c => c.name);
    }

    async createOrUpdateCard(collectionName: string, card: any, idField: string = 'id'): Promise<any> {
        if (!this.initialized) {
            await this.initialize();
        }

        const collection = this.getCollection(collectionName);
        const existingCard = collection.findOne({ [idField]: card[idField] });

        if (existingCard) {
            Object.assign(existingCard, card);
            collection.update(existingCard);
            return existingCard;
        } else {
            const newCard = collection.insert(card);
            return newCard;
        }
    }

    async addCardsToCollection(collectionName: string, cards: any[], idField: string = 'id'): Promise<any[]> {
        if (!this.initialized) {
            await this.initialize();
        }

        const collection = this.getCollection(collectionName);
        const results = [];

        for (const card of cards) {
            const existingCard = collection.findOne({ [idField]: card[idField] });

            if (existingCard) {
                Object.assign(existingCard, card);
                collection.update(existingCard);
                results.push(existingCard);
            } else {
                const newCard = collection.insert(card);
                results.push(newCard);
            }
        }

        return results;
    }

    async getAllCards(collectionName: string): Promise<any[]> {
        if (!this.initialized) {
            await this.initialize();
        }

        const collection = this.getCollection(collectionName);
        return collection.find();
    }

    async getCardById(collectionName: string, cardId: string, idField: string = 'id'): Promise<any | null> {
        if (!this.initialized) {
            await this.initialize();
        }

        const collection = this.getCollection(collectionName);
        return collection.findOne({ [idField]: cardId });
    }

    async deleteCard(collectionName: string, cardId: string, idField: string = 'id'): Promise<boolean> {
        if (!this.initialized) {
            await this.initialize();
        }

        const collection = this.getCollection(collectionName);
        const card = collection.findOne({ [idField]: cardId });

        if (card) {
            collection.remove(card);
            return true;
        }

        return false;
    }

    deleteCollection(collectionName: string): boolean {
        this.collections.delete(collectionName);

        if (this.db.getCollection(collectionName)) {
            this.db.removeCollection(collectionName);
            return true;
        }

        return false;
    }
    saveDatabase(): Promise<void> {
        return new Promise((resolve, reject) => {
            this.db.saveDatabase((err) => {
                if (err) {
                    return reject(err);
                }
                resolve();
            });
        });
    }
}

export default DatabaseService;