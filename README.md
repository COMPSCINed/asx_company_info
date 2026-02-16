# ASX Company Information

A Phoenix LiveView application for fetching and displaying ASX company information and market data with advanced stock comparison capabilities.

## Quick Start

1. Install dependencies:
   ```bash
   mix setup
   ```

2. Configure API credentials in `.env`:
   ```bash
   API_BASE_URL=your_api_url
   API_KEY=your_api_key
   ```

3. Start the server:
   ```bash
   mix phx.server
   ```

4. Visit the application:
   - **Single Stock View**: `http://localhost:4000`
   - **Stock Comparison**: `http://localhost:4000/compare`

## Features

### Core Features
- **Single Stock View**: Detailed company information and real-time quote data for individual ASX stocks
- **Multi-Stock Comparison**: Compare up to 4 ASX stocks side-by-side with smart insights

### Stock Comparison Features
- **Side-by-side comparison**: View up to 4 stocks simultaneously in a responsive grid layout
- **Smart comparison insights**: Automatic calculation of best/worst performers, highest/lowest prices, total market value, and average change
- **Interactive controls**: Add/remove stocks, clear all, and popular stock quick-select
- **Maximum limit enforcement**: Prevents UI clutter by limiting to 4 stocks per comparison

## Technical Architecture

### Core Technical Features
- **Parallel data fetching**: Company info and quote data fetched concurrently using `assign_async` for better performance
- **Modern UI**: Responsive design with DaisyUI skeleton loading states
- **Zoi validation**: Lightweight input validation without Ecto Changeset overhead
- **Decimal types**: Use Decimal for financial precision (optional)
- **Result helpers**: Better handling of result types
- **LiveView Structure**: Separate `ComparisonLive.Index` module with dedicated `/compare` route
- **State Management**: `MapSet` for quote data storage with `AsyncResult` for fetch operations
- **Data Flow**: Automatic metric recalculation on every change
- **Decimal Comparison**: Custom comparison logic using `Decimal.compare/2` for accurate financial calculations
- **Clear separation**: Single-view and comparison-view logic kept distinct but share common utilities (`TickHandling`)

## Addressing User Pain Points

Based on the usiness-case-stock-comparison.md, this implementation directly addresses key user pain points:

### Problem: Inefficient Multi-Tab Workflow
**Solution**: Dedicated comparison page (`/compare`) allows users to view up to 4 stocks side-by-side without browser tab switching.

### Problem: Cognitive Overload from Manual Comparison
**Solution**: Smart comparison insights automatically calculate and highlight:
- Best/worst performers by percentage change
- Highest/lowest current prices
- Total market value aggregation
- Average percentage change across all stocks

### Problem: Limited Mobile Experience
**Solution**: Fully responsive grid layout (1 column mobile, 2-4 columns desktop) with touch-friendly controls.

## Implementation Decisions & Trade-offs

### Architecture Choice: MapSet with AsyncResult
- **Why MapSet?**: Provides O(log n) operations for add/remove with automatic deduplication, but could be overkill as we only compare 4 of them.
- **Why AsyncResult?**: Tracks individual fetch operations with proper loading/error states without the need to do extra states management

### Data Structure: Quote-Only Comparison
- **Decision**: Comparison view shows financial metrics only (no company descriptions)
- **Rationale**: Reduces cognitive load and focuses on comparative analysis
- **Benefit**: Faster loading and cleaner UI for comparison tasks

### Maximum 4 Stocks Limit
- **Decision**: Enforced limit to prevent UI clutter and API overload
- **Rationale**: Matches user behavior (3-5 stocks average) and maintains performance
- **User Benefit**: Clean, readable interface without overwhelming data

## Future Considerations

### Phase 2 Enhancements (Planned)
- **URL state persistence**: Shareable comparison links
- **Saved comparisons**: Backend storage for user comparisons

### Phase 3 Advanced Features
- **Real-time updates**: Timer-based refresh or webhook/push notifications for stock changes
- **Performance charts**: Visual comparison overlays
- **GraphQL API**: Potential for single API call returning both company and quote data
- **Supervisor pattern**: Could add supervision for more complex task management

### Notes
Tests make real API requests, but we could mock them to test accumulated values such as Average Change.
Some of the implementations (generalizations) may be overkill.
