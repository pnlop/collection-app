import loki, { Loki, Collection } from 'lokijs';

interface CollectionMetadata {
    name: string;
    description: string;
    createdAt: Date;
    updatedAt: Date;
}

class DatabaseService {
    private db: Loki;
    private collections: Map<string, Collection<any>> = new Map();
    private initialized: boolean = false;
    private metaCollection: Collection<CollectionMetadata> | null = null;

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
                this.metaCollection = this.db.getCollection('collection_metadata');
                if (!this.metaCollection) {
                    this.metaCollection = this.db.addCollection('collection_metadata', {
                        indices: ['name']
                    });
                }
                this.initialized = true;
                resolve();
            });
        });
    }

    async createCollection(name: string, description: string = ''): Promise<CollectionMetadata> {
        if (!this.initialized) {
            await this.initialize();
        }

        if (!name || name.trim() === '') {
            throw new Error('Collection name cannot be empty');
        }

        if (name === 'collection_metadata') {
            throw new Error('This collection name is reserved');
        }

        if (this.metaCollection!.findOne({ name })) {
            throw new Error(`Collection "${name}" already exists`);
        }

        const collection = this.db.addCollection(name, {
            indices: ['id']
        });
        this.collections.set(name, collection);

        const now = new Date();
        const metadata: CollectionMetadata = {
            name,
            description,
            createdAt: now,
            updatedAt: now
        };

        this.metaCollection!.insert(metadata);

        await this.saveDatabase();

        return metadata;
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

    listCollections(): { name: string; description: string }[] {
        if (!this.initialized || !this.metaCollection) {
            return [];
        }

        return this.metaCollection.find().map(meta => ({
            name: meta.name,
            description: meta.description
        }));
    }

    async deleteCollection(collectionName: string): Promise<boolean> {
        if (!this.initialized) {
            await this.initialize();
        }

        if (collectionName === 'collection_metadata') {
            return false;
        }

        this.collections.delete(collectionName);

        const metadata = this.metaCollection!.findOne({ name: collectionName });
        if (metadata) {
            this.metaCollection!.remove(metadata);
        }

        if (this.db.getCollection(collectionName)) {
            this.db.removeCollection(collectionName);
            await this.saveDatabase();
            return true;
        }

        return false;
    }

    async updateCollectionMetadata(name: string, description: string): Promise<CollectionMetadata | null> {
        if (!this.initialized) {
            await this.initialize();
        }

        const metadata = this.metaCollection!.findOne({ name });
        if (!metadata) {
            return null;
        }

        metadata.description = description;
        metadata.updatedAt = new Date();
        this.metaCollection!.update(metadata);

        await this.saveDatabase();
        return metadata;
    }

    async getCollectionMetadata(name: string): Promise<CollectionMetadata | null> {
        if (!this.initialized) {
            await this.initialize();
        }

        return this.metaCollection!.findOne({ name }) || null;
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